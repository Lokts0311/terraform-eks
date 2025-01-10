resource "aws_efs_file_system" "eks" {
  creation_token = "eks"

  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
  encrypted = true

  # lifecycle_policy {
  #     transition_to_ia = "AFTER_30_DAYS"
  # }
}

resource "aws_efs_mount_target" "zone_a" {
    file_system_id = aws_efs_file_system.eks.id
    subnet_id = aws_subnet.private_zone1.id
    security_groups = [ aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id ]
}

resource "aws_efs_mount_target" "zone_b" {
    file_system_id = aws_efs_file_system.eks.id
    subnet_id = aws_subnet.private_zone2.id
    security_groups = [ aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id ]
}

# Grant Access: IAM Role for Service Account (IRSA)
# create trust policy
data "aws_iam_policy_document" "efs_csi_driver" {
statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    # Require service account when using openid
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:efs-csi-controller-sa"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "efs_csi_driver" {
  name = "${aws_eks_cluster.eks.name}-efs-csi-driver"
  assume_role_policy = data.aws_iam_policy_document.efs_csi_driver.json
}

resource "aws_iam_role_policy_attachment" "efs_csi_driver" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  role = aws_iam_role.efs_csi_driver.name
}

resource "helm_release" "efs_csi_driver" {
  name = "aws-efs-csi-driver"

  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  chart = "aws-efs-csi-driver"
  namespace = "kube-system"
  version = "3.12.1"

  set {
    name  = "controller.serviceAccount.name"
    value = "efs-csi-controller-sa"
  }

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.efs_csi_driver.arn # dynamic pass IAM role for efs_csi_driver
  }

  depends_on = [
    aws_efs_mount_target.zone_a,
    aws_efs_mount_target.zone_b
  ]
}

# Create custom Kubernetes Storage Class for EFS
resource "kubernetes_storage_class_v1" "efs" {
  metadata {
    name = "efs"
  }

  storage_provisioner = "efs.csi.aws.com"

  # Parameters List: https://github.com/kubernetes-sigs/aws-efs-csi-driver
  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.eks.id
    directoryPerms   = "700"
  }

  mount_options = ["iam"]

  depends_on = [helm_release.efs_csi_driver]
}