provider "aws" {
    region = var.region
}

provider "helm" {
    kubernetes {
        host                   = data.aws_eks_cluster.eks.endpoint
        cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
        token                  = data.aws_eks_cluster_auth.eks.token
    }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks)
  token                  = data.aws_eks_cluster_auth.eks
}