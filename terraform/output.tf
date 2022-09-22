output "aws_ecr_repository_url" {
	value = module.aws_ecr_repository.aws_ecr_repository_url
}
output "aws_ecr_registry_url" {
	value = local.aws_ecr_registry_url
}
# output "docker_registry_image" {
# 	value = docker_registry_image.hivemind_hiring_challange.name
# }
output "aws_eks_cluster_control_plane_api_endpoint" {
	value = module.aws_eks_cluster.control_plane_api_endpoint
}
output "aws_eks_cluster_certificate_authority_data" {
	value = module.aws_eks_cluster.certificate_authority_data
}
