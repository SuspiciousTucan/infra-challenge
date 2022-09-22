locals {
  aws_policy_arn_prefix         = "arn:aws:iam::aws:policy/%s"
  aws_control_plane_policy_arns = toset([for k in concat(var.control_plane_defaul_policies, var.control_plane_extra_policies) : format(local.aws_policy_arn_prefix, k)])
  aws_nodes_policy_arns         = toset([for k in concat(var.nodes_defaul_policies, var.nodes_extra_policies) : format(local.aws_policy_arn_prefix, k)])
}


resource "aws_iam_role" "control_plane" {
  name = "eks_control_plane"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action : "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
  tags = local.iam_tags
}

resource "aws_iam_role" "nodes" {
  name = "eks_workers"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action : "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
  tags = local.iam_tags
}

# This was included to try to fix the loadbalancer controller not working.
# Didnt help.
resource "aws_iam_role" "cluster" {
  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role_policy.json
  name               = format("irsa-%s-aws-node", aws_eks_cluster.eks_cluster.name)
}


resource "aws_iam_role_policy_attachment" "control_plane" {
  for_each   = local.aws_control_plane_policy_arns
  role       = aws_iam_role.control_plane.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "nodes" {
  for_each   = local.aws_nodes_policy_arns
  role       = aws_iam_role.nodes.name
  policy_arn = each.value
}
