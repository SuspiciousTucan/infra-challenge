#------------------------------------ GENERIC ---------------------------------#
variable "aws_region" {
  default     = "us-east-1"
  type        = string
  description = "Region in which to deploy cluster."
}

variable "aws_availability_zones" {
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  type        = list(string)
  description = "List of availability zones on which to deploy the cluster."
}

variable "default_tags" {
  default     = {}
  type        = map(string)
  description = "Map of default tags to add to provisioned resources."
}

variable "extra_tags" {
  default     = {}
  type        = map(string)
  description = "Map of extra tags to add to provisioned resources."
}

variable "default_security_group_tags" {
  default     = {}
  type        = map(string)
  description = "Map of default tags to add to Security Group resources."
}

variable "extra_security_group_tags" {
  default     = {}
  type        = map(string)
  description = "Map of extra tags to add to Security Group resources."
}

variable "default_iam_tags" {
  default     = {}
  type        = map(string)
  description = "Map of extra tags to add to IAM resources."
}

variable "extra_iam_tags" {
  default     = {}
  type        = map(string)
  description = "Map of extra tags to add to IAM resources."
}

variable "default_vpc_tags" {
  default     = {}
  type        = map(string)
  description = "Map of default tags to add to VPC resources."
}

variable "extra_vpc_tags" {
  default     = {}
  type        = map(string)
  description = "Map of extra tags to add to VPC resources."
}

variable "default_ssh_tags" {
  default     = {}
  type        = map(string)
  description = "Map of default tags to add to ssh keys."
}

variable "extra_ssh_tags" {
  default     = {}
  type        = map(string)
  description = "Map of extra tags to add to ssh keys."
}

variable "default_cluster_tags" {
  default     = {}
  type        = map(string)
  description = "Map of default tags to add to ssh keys."
}

variable "extra_cluster_tags" {
  default     = {}
  type        = map(string)
  description = "Map of extra tags to add to ssh keys."
}

variable "default_public_worker_tags" {
  default     = {}
  type        = map(string)
  description = "Map of default tags to add to worker deployed on public subnet."
}

variable "extra_public_worker_tags" {
  default     = {}
  type        = map(string)
  description = "Map of extra tags to add to worker deployed on public subnet."
}

variable "default_private_worker_tags" {
  default     = {}
  type        = map(string)
  description = "Map of default tags to add to worker deployed on private subnet."
}

variable "extra_private_worker_tags" {
  default     = {}
  type        = map(string)
  description = "Map of extra tags to add to worker deployed on private subnet."
}
#------------------------------------ /GENERIC --------------------------------#




#------------------------------------ IAM -------------------------------------#

# TODO: Defaults should meybe depend on the cluster config.
# I.e. it's not good to add CloudWatchFullAccess if logs are not enabled!
# A quick solution could be to remove extra policies from the defaults and
# require user to inject them as extras, still suboptimal as user
# could insert wrong policies or forget some
# TODO: Policies should probably be validated somehow.
variable "control_plane_defaul_policies" {
  default = [
    "AmazonEKSClusterPolicy",
    "AmazonEKSVPCResourceController"
  ]
  type        = list(string)
  description = "Default policies for control plane nodes."
}

variable "nodes_defaul_policies" {
  default = [
    "AmazonEKSWorkerNodePolicy",
    "AmazonEC2ContainerRegistryReadOnly",
    "AmazonEKS_CNI_Policy",
    "CloudWatchFullAccess",
    "AmazonPrometheusRemoteWriteAccess"
  ]
  type        = list(string)
  description = "Default policies for worker nodes."
}

variable "nodes_extra_policies" {
  default     = []
  type        = list(string)
  description = "Extra policies for control plane nodes."
}

variable "control_plane_extra_policies" {
  default     = []
  type        = list(string)
  description = "Extra policies for worker nodes."
}

#------------------------------------ /IAM ------------------------------------#




#------------------------------------ SSH -------------------------------------#
variable "ssh_access_keys" {
  default = []
  type = list(object({
    key_name   = string
    public_key = string
  }))
  description = "List of ssh public keys for resources remote access."
}
#------------------------------------ /SSH ------------------------------------#




#------------------------------------ VPC -------------------------------------#
variable "vpc_cidr_block" {
  default     = "10.0.0.0/16"
  type        = string
  description = "VPC's classless inter-domain routing block."
}

# TODO: Very ugly solution, should at least add validation to check if
# provided azs are in the aws_availability_zones variable and check that cidrs
# dont overlap. Temporary!
variable "vpc_public_subnets" {
  default = [
    "10.0.1.0/24",
    "10.0.3.0/24",
    "10.0.5.0/24"
  ]
  type        = list(string)
  description = "List of public subnets cidr."
}

variable "vpc_private_subnets" {
  default = [
    "10.0.2.0/24",
    "10.0.4.0/24",
    "10.0.6.0/24"
  ]
  type        = list(string)
  description = "List of private subnets cidr."
}
#------------------------------------ /VPC ------------------------------------#




#------------------------------------ EKS -------------------------------------#
variable "cluster_name" {
  default     = "default"
  type        = string
  description = "Name of the EKS cluster to create."
}

variable "cluster_version" {
  default     = "1.23"
  type        = string
  description = "Desired Kubernetes master version."
}

variable "cluster_service_cidr" {
  default     = "172.20.0.0/16"
  type        = string
  description = "Classless inter domain routing block for Kubernetes services."
}


variable "resources_encryption" {
  default     = false
  type        = bool
  description = "Whether to encrypt etcd resources."
}
variable "encryption_components" {
  default     = ["secrets"]
  type        = list(string)
  description = "List of control plane resources to encrypt."
}


variable "enable_logs" {
  default     = false
  type        = bool
  description = "Whether to pipe logs to AWS CloudWatch."
}
# TODO: Add validation, should be 0 < log_retention_period <= 30
variable "log_retention_period" {
  default     = 7
  type        = number
  description = "Configure for how many days CloudWatch will retain logs."
}
variable "log_components" {
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
#------------------------------------ /EKS ------------------------------------#


#-------------------------------- NODE GROUPS ---------------------------------#
variable "public_worker_node_group_labels" {
  default = {}
  type = map
  description = "Map of labels to add to workers deployed on public subnet."
}

variable "private_worker_node_group_labels" {
  default = {}
  type = map
  description = "Map of labels to add to workers deployed on private subnet."
}

variable "public_worker_node_group" {
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

variable "private_worker_node_group" {
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
#-------------------------------- /NODE GROUPS --------------------------------#
