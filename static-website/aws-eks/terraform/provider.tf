terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source   = "hashicorp/kubernetes"
      version  = "~> 3.0.1"
    }
    helm = {
      source   = "hashicorp/helm"
      version  = "~> 3.1.1"
    }
    tls = {
      source   = "hashicorp/tls"
      version  = "~> 4.2.1"
    }
  }
}

provider "aws" {
  region                      = var.aws_region
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

provider "kubernetes" {
  host                   = aws_eks_cluster.nginx.endpoint
  cluster_ca_certificate = base64decode(
    aws_eks_cluster.nginx.certificate_authority[0].data
  )
  token = data.aws_eks_cluster_auth.nginx.token
}

provider "helm" {
  kubernetes = {
    host                   = aws_eks_cluster.nginx.endpoint
    cluster_ca_certificate = base64decode(
      aws_eks_cluster.nginx.certificate_authority[0].data
    )
    token = data.aws_eks_cluster_auth.nginx.token
  }
}
