provider "aws" {
  profile = "default"
  region = var.region
}

############################################################
# Helm Provider for deploying helm charts in eks
############################################################
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.default.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.default.id]
      command     = "aws"
    }
  }
}


############################################################
# Kubernetes Provider for deploying helm charts in eks
############################################################
provider "kubernetes" {
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  # token                  = data.aws_eks_cluster_auth.default.token

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.default.id]
    command     = "aws"
  }
}


#################################################################
# Data
#################################################################
data "aws_eks_cluster" "default" {
  name = module.eks.cluster_name
  depends_on = [ module.eks.cluster_name ]
}


##################################################################
# Required Version
##################################################################

terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.11.0"
    }
  }

  required_version = "~> 1.5.7"
}