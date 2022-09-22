resource "aws_eks_node_group" "eks_public_workers" {
  for_each = { for k, i in aws_subnet.vpc_public_subnets : k => i }

  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.cluster_name}_worker_${each.value.availability_zone}_public"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = [each.value.id]

  capacity_type  = var.public_worker_node_group.capacity_type
  disk_size      = var.public_worker_node_group.disk_size
  instance_types = var.public_worker_node_group.instance_type

  labels = local.public_worker_node_group_labels

  tags = local.public_worker_tags


  # TODO : Mmmm, not sure how to deal with this.
  # dynamic "access_config" {
  #   for_each = aws_key_pair.eks_cluster_access_keys
  #   content {
  #     remote_access {
  #   		ec2_ssh_key = aws_key_pair.eks_cluster.key_name
  #   	}
  #   }
  # }

  taint {
    key    = "subnetwork-type"
    value  = "public"
    effect = "PREFER_NO_SCHEDULE"
  }

  scaling_config {
    desired_size = var.public_worker_node_group.desired_size
    max_size     = var.public_worker_node_group.max_size
    min_size     = var.public_worker_node_group.min_size
  }

  update_config {
    max_unavailable_percentage = var.public_worker_node_group.max_unavailable_percentage
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  depends_on = [
    aws_iam_role_policy_attachment.nodes
  ]
}

resource "aws_eks_node_group" "eks_private_workers" {
  for_each = { for k, i in aws_subnet.vpc_private_subnets : k => i }

  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.cluster_name}_worker_${each.value.availability_zone}_private"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = [each.value.id]

  capacity_type  = var.private_worker_node_group.capacity_type
  disk_size      = var.private_worker_node_group.disk_size
  instance_types = var.private_worker_node_group.instance_type

  labels = local.private_worker_node_group_labels

  tags = local.private_worker_tags

  taint {
    key    = "subnetwork-type"
    value  = "private"
    effect = "PREFER_NO_SCHEDULE"
  }

  scaling_config {
    desired_size = var.private_worker_node_group.desired_size
    max_size     = var.private_worker_node_group.max_size
    min_size     = var.private_worker_node_group.min_size
  }

  update_config {
    max_unavailable_percentage = var.private_worker_node_group.max_unavailable_percentage
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  depends_on = [
    aws_iam_role_policy_attachment.nodes
  ]
}
