output "certificate_authority_data" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "control_plane_api_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_oidc_issuer" {
  value = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}
