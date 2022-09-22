resource "aws_cloudwatch_log_group" "eks_control_plane" {
  count = var.enable_logs ? 1 : 0

  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.log_retention_period
  kms_key_id        = aws_kms_key.logs_encryption[0].arn
}
