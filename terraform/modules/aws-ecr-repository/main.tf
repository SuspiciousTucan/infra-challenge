locals {
  tags = merge(
    var.default_repository_tags,
    var.extra_repository_tags
  )
}

resource "aws_ecr_repository" "repository" {
  name = var.repository_name
  encryption_configuration {
    encryption_type = "AES256"
  }
  force_delete         = var.force_delete
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = false
  }
  tags = local.tags
}
