locals {
  public_worker_node_group_labels = merge(
    var.public_worker_node_group_labels,
    {
      "networking.aws.com/subnet_type" = "public"
    }
  )
  private_worker_node_group_labels = merge(
    var.private_worker_node_group_labels,
    {
      "networking.aws.com/subnet_type" = "private"
    }
  )
}

locals {

  tags = merge(
    var.default_tags,
    var.extra_tags
  )

  security_group_tags = merge(
    local.tags,
    var.default_security_group_tags,
    var.extra_security_group_tags
  )

  iam_tags = merge(
    local.tags,
    var.default_iam_tags,
    var.extra_iam_tags
  )

  vpc_tags = merge(
    local.tags,
    var.default_vpc_tags,
    var.extra_vpc_tags
  )

  public_subnet_tags = merge(
    local.vpc_tags,
    {
      "kubernetes.io/cluster/${var.cluster_name}" = "shared",
      "kubernetes.io/role/elb"                    = "1"
    }
  )

  private_subnet_tags = merge(
    local.vpc_tags,
    {
      "kubernetes.io/cluster/${var.cluster_name}" = "shared",
      "kubernetes.io/role/internal-elb"           = "1"
    }
  )

  ssh_tags = merge(
    local.tags,
    var.default_ssh_tags,
    var.extra_ssh_tags
  )

  cluster_tags = merge(
    local.tags,
    var.default_cluster_tags,
    var.extra_cluster_tags
  )

  public_worker_tags = merge(
    local.tags,
    local.cluster_tags,
    var.default_public_worker_tags,
    var.extra_public_worker_tags
  )

  private_worker_tags = merge(
    local.tags,
    local.cluster_tags,
    var.default_private_worker_tags,
    var.extra_private_worker_tags
  )
}

data "aws_region" "current" {
}

data "aws_caller_identity" "current" {
}

data "aws_partition" "current" {
}


data "aws_iam_policy_document" "cluster_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_oidc_provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks_oidc_provider.arn]
      type        = "Federated"
    }
  }
}
