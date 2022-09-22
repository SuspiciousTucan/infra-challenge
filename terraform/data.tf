data "aws_caller_identity" "current" {
}
data "aws_ecr_authorization_token" "token" {
}
data "aws_region" "current" {
}

locals {
  aws_ecr_registry_url = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
}
