# TODO: Region selection should be handled via aliases. That way we can provision multi region clusters!
provider "aws" {
  region = var.aws_region

  # TODO: Remove and use env vars!
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  
}


provider "docker" {
  host = var.docker_socket

  registry_auth {
    address  = local.aws_ecr_registry_url
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}


provider "kubernetes" {
  host                   = module.aws_eks_cluster.control_plane_api_endpoint
  cluster_ca_certificate = base64decode(module.aws_eks_cluster.certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", "${var.eks_cluster_name}"]
    command     = "aws"
  }
}


# Maybe redundant?
provider "helm" {
  kubernetes {
    host                   = module.aws_eks_cluster.control_plane_api_endpoint
    cluster_ca_certificate = base64decode(module.aws_eks_cluster.certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", "${var.eks_cluster_name}"]
      command     = "aws"
    }
  }
}
