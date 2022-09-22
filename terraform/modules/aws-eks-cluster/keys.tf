resource "aws_key_pair" "eks_cluster_access_keys" {
  for_each = { for k in var.ssh_access_keys : k.key_name => k }

  key_name   = each.value.key_name
  public_key = each.value.public_key

  tags = local.ssh_tags
}
