# ---------------------------------- AWS ------------------------------------- #
#
variable "aws_access_key" {
  default = ""
  type = string
  description = "AWS access key"
}

variable "aws_secret_key" {
  default = ""
  type = string
  description = "AWS secret key"
}

variable "aws_region" {
  default     = "us-east-1"
  type        = string
  description = "AWS region to use for infrastructure deployment."
}


variable "aws_availability_zones" {
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  type        = list(string)
  description = "List of AWS availability zones on which to deploy the infrastructure"
}
#
# ---------------------------------- /AWS ------------------------------------ #




# ---------------------------------- DOCKER ---------------------------------- #
#
variable "docker_socket" {
  type        = string
  default     = "unix:///var/run/docker.sock"
  description = "Path to the socket used by the Docker daemon"
}
#
# ---------------------------------- /DOCKER --------------------------------- #




# ---------------------------------- EKS ------------------------------------- #
#
variable "eks_cluster_name" {
  default     = "default"
  type        = string
  description = "Name of the EKS cluster to create."
}


variable "eks_cluster_version" {
  default     = "1.23"
  type        = string
  description = "Desired Kubernetes master version."
}


variable "eks_extra_tags" {
  default     = {}
  type        = map(string)
  description = "Map of extra tags to add to provisioned resources."
}


variable "eks_control_plane_extra_policies" {
  default     = []
  type        = list(string)
  description = "Extra policies for worker nodes."
}
variable "eks_nodes_extra_policies" {
  default     = []
  type        = list(string)
  description = "Extra policies for control plane nodes."
}


variable "eks_ssh_access_keys" {
  default = []
  type = list(object({
    key_name   = string
    public_key = string
  }))
  description = "List of ssh public keys for resources remote access."
}


variable "eks_vpc_cidr_block" {
  default     = "10.0.0.0/16"
  type        = string
  description = "VPC's classless inter-domain routing block."
}
# TODO: Very ugly solution, should at least add validation to check if
# provided azs are in the aws_availability_zones variable and check that cidrs
# dont overlap. Temporary!
variable "eks_vpc_public_subnets" {
  default = [
    "10.0.1.0/24",
    "10.0.3.0/24",
    "10.0.5.0/24"
  ]
  type        = list(string)
  description = "List of public subnets cidr."
}
variable "eks_vpc_private_subnets" {
  default = [
    "10.0.2.0/24",
    "10.0.4.0/24",
    "10.0.6.0/24"
  ]
  type        = list(string)
  description = "List of private subnets cidr."
}


variable "eks_resources_encryption" {
  default     = false
  type        = bool
  description = "Whether to encrypt etcd resources."
}
variable "eks_encryption_components" {
  default     = ["secrets"]
  type        = list(string)
  description = "List of control plane resources to encrypt."
}


variable "eks_enable_logs" {
  default     = false
  type        = bool
  description = "Whether to pipe logs to AWS CloudWatch."
}
# TODO: Add validation, should be 0 < log_retention_period <= 30
variable "eks_log_retention_period" {
  default     = 7
  type        = number
  description = "Configure for how many days CloudWatch will retain logs."
}
variable "eks_log_components" {
  default = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
  type        = list(string)
  description = "List of control plane components for which to gather logs."
}


variable "eks_public_worker_node_group" {
  default = {
    capacity_type              = "ON_DEMAND" # Or "SPOT"
    disk_size                  = 20
    instance_type              = ["t3.medium"]
    desired_size               = 2
    max_size                   = 4
    min_size                   = 1
    max_unavailable_percentage = 50
  }
  type = object({
    capacity_type              = string,
    disk_size                  = number
    instance_type              = list(string)
    desired_size               = number
    max_size                   = number
    min_size                   = number
    max_unavailable_percentage = number
  })
  description = "Public subnet worker nodes configuration."
}
variable "eks_private_worker_node_group" {
  default = {
    capacity_type              = "ON_DEMAND" # Or "SPOT"
    disk_size                  = 20
    instance_type              = ["t3.medium"]
    desired_size               = 2
    max_size                   = 4
    min_size                   = 1
    max_unavailable_percentage = 50
  }
  type = object({
    capacity_type              = string,
    disk_size                  = number
    instance_type              = list(string)
    desired_size               = number
    max_size                   = number
    min_size                   = number
    max_unavailable_percentage = number
  })
  description = "Private subnet worker nodes configuration."
}
#
# ---------------------------------- /EKS ------------------------------------ #




# ---------------------------------- ECR ------------------------------------- #
#
variable "ecr_repository_name" {
  type        = string
  default     = "default"
  description = "Name of the Elastic Container Registry repository created to host container images."
}
variable "ecr_repository_force_delete" {
  type        = bool
  default     = false
  description = "Enabled force delete which deletes the repository even if it holds images."
}
variable "ecr_repository_image_tag_mutability" {
  default     = "MUTABLE"
  type        = string
  description = "Enabled force delete which deletes the repository even if it holds images."
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.ecr_repository_image_tag_mutability)
    error_message = "Accepted values for image_tag_mutability are MUTABLE or IMMUTABLE"
  }
}
#
# ---------------------------------- /ECR ------------------------------------ #




# ------------------------------- NLB & ALB ---------------------------------- #
#
variable "aws_load_balancer_controller_sa_name" {
  default     = "aws-load-balancer-controller"
  type        = string
  description = "Service account name associated  with the AWS load balancer controller."
}
variable "aws_load_balancer_controller_namespace" {
  default     = "kube-system"
  type        = string
  description = "Kubernetes namespace in which to deploy AWS load balancer Controller."
}
#
# ------------------------------- /NLB & ALB --------------------------------- #




# ---------------------------------- HELM ------------------------------------ #
#
# variable "helm_charts" {
# 	type = list(object({
# 		name = string,
# 		repository = string
# 		chart = string,
# 		namespace = string,
# 		values_file = string
# 	}))
#   default = []
# 	description = "List of helm charts to deploy upon cluster creation."
# }
#
# ---------------------------------- /HELM ----------------------------------- #
