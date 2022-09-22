resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.control_plane.arn

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    # public_access_cidrs = local.subnets_cidrs
    subnet_ids = concat(aws_subnet.vpc_public_subnets[*].id, aws_subnet.vpc_private_subnets[*].id)
  }

  enabled_cluster_log_types = var.log_components

  dynamic "encryption_config" {
    for_each = var.resources_encryption ? [1] : []

    content {
      provider {
        key_arn = aws_kms_key.resources_encryption[0].arn
      }
      resources = var.encryption_components
    }
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.cluster_service_cidr
    ip_family         = "ipv4"
  }

  tags = local.cluster_tags

  version = var.cluster_version

  depends_on = [
    aws_iam_role_policy_attachment.control_plane,
    aws_cloudwatch_log_group.eks_control_plane
  ]
}
