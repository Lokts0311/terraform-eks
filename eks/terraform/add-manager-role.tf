data "aws_caller_identity" "current" {}

# IAM user eks_admin
resource "aws_iam_role" "eks_admin" {

  name = "${var.env}-${var.eks_name}-eks-admin"

  # Create Trust Relationship for IAM user
  assume_role_policy = jsonencode(
    {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Principal": {
          # Allowing all identity (users, role, group, services) within this AWS account to assume this role
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "eks_admin" {

  name = "AmazonEKSAdminPolicy"

  policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "eks:*"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": "iam:PassRole",
          "Resource": "*",
          "Condition": {
            "StringEquals": {
              "iam:PassedToService": "eks.amazonaws.com"
            }
          }
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "eks_admin" {
  role       = aws_iam_role.eks_admin.name
  policy_arn = aws_iam_policy.eks_admin.arn
}


# IAM User manager
resource "aws_iam_user" "manager" {
  name               = "manager"
}

resource "aws_iam_policy" "eks_assume_admin" {
  name = "AmazonEKSAssumeAdminPolicy"

  # Add Permission for other user to call sts:AssumeRole
  policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": "sts:AssumeRole",
          "Resource": "${aws_iam_role.eks_admin.arn}"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "manager" {
  role       = aws_iam_role.manager.name
  policy_arn = aws_iam_policy.eks_assume_admin.arn
}

resource "aws_eks_access_entry" "manager" {
  cluster_name = aws_eks_cluster.eks.name
  principal_arn = aws_iam_role.eks_admin.arn
  kubernetes_groups = ["my-admin"]
}