resource "helm_release" "secrets_csi_drivr" {
    name = "secrets-store-csi-driver"

    repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
    chart = "secrets-store-csi-driver"
    namespace = "kube-system"
    version = "1.4.7"

    # Sync to Secret data and using Secret data as cotainer environment variables
    set {
      name = "syncSecret.enable"
      value = true
    }

    depends_on = [ helm_release.efs_csi_driver ]
  
}

resource "helm_release" "secrets_csi_drivr_aws_provider" {
  name = "secrets-store-csi-driver-provider-aws"

  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart = "secrets-store-csi-driver-provider-aws"
  namespace = "kube-system"
  version = "0.3.10"

  depends_on = [ helm_release.secrets_csi_drivr ]
}

# create trust policy
data "aws_iam_policy_document" "myapp_secrets" {
statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    # Require service account when using openid
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:example-8:myapp-sa"] # Using the service account myapp-sa in namespace example-8
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "myapp_secrets" {
  name = "${aws_eks_cluster.eks.name}-myapp-secrets"
  assume_role_policy = data.aws_iam_policy_document.myapp_secrets.json
}

resource "aws_iam_policy" "myapp_secrets" {
    name = "${aws_eks_cluster.eks.name}-myapp-secrets"

    # https://docs.aws.amazon.com/secretsmanager/latest/userguide/auth-and-access_iam-policies.html#auth-and-access_examples-read-and-describe
    policy = jsonencode({
        Version = "2012-10-17"

        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "secretsmanager:GetSecretValue",
                    "secretsmanager:DescribeSecret"
                ],
                "Resource": "SecretARN"
            }
        ]
    })
  
}

resource "aws_iam_role_policy_attachment" "myapp_secrets" {
  policy_arn = aws_iam_policy.myapp_secrets.arn
  role = aws_iam_role.efs_csi_driver.name
}