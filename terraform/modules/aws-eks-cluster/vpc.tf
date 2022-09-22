locals {
  subnets_cidrs = concat(
    var.vpc_public_subnets,
    var.vpc_private_subnets
  )
}


resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = local.vpc_tags
}


resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = local.vpc_tags
}


resource "aws_eip" "aws_nat_eip" {
  count = length(var.vpc_public_subnets)
  vpc   = true

  tags = local.vpc_tags
}


resource "aws_nat_gateway" "aws_nat_gateway" {
  count = length(var.aws_availability_zones)

  allocation_id     = aws_eip.aws_nat_eip[count.index].id
  connectivity_type = "public"
  subnet_id         = aws_subnet.vpc_public_subnets[count.index].id
}


resource "aws_subnet" "vpc_public_subnets" {
  count = length(var.vpc_public_subnets)

  vpc_id                              = aws_vpc.vpc.id
  availability_zone                   = element(concat(var.aws_availability_zones, [""]), count.index)
  cidr_block                          = element(concat(var.vpc_public_subnets, [""]), count.index)
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"

  tags = local.public_subnet_tags
}
resource "aws_subnet" "vpc_private_subnets" {
  count = length(var.vpc_private_subnets)

  vpc_id                              = aws_vpc.vpc.id
  availability_zone                   = element(concat(var.aws_availability_zones, [""]), count.index)
  cidr_block                          = element(concat(var.vpc_private_subnets, [""]), count.index)
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "ip-name"

  tags = local.private_subnet_tags
}


resource "aws_route_table" "vpc_public_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = local.vpc_tags
}
resource "aws_route_table" "vpc_private_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = local.vpc_tags
}


resource "aws_route" "vpc_public_internet_gw" {
  route_table_id         = aws_route_table.vpc_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}
# TODO: This is probably wrong!
resource "aws_route" "eks_private_nat_gw" {
  route_table_id         = aws_route_table.vpc_private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.aws_nat_gateway[0].id
}


resource "aws_route_table_association" "eks_cluster_public_1" {
  count = length(var.aws_availability_zones)

  subnet_id      = aws_subnet.vpc_public_subnets[count.index].id
  route_table_id = aws_route_table.vpc_public_route_table.id
}
resource "aws_route_table_association" "eks_cluster_private_1" {
  count = length(var.aws_availability_zones)

  subnet_id      = aws_subnet.vpc_private_subnets[count.index].id
  route_table_id = aws_route_table.vpc_private_route_table.id
}


# TODO: Default security group should be more strict!
resource "aws_default_security_group" "vpc_default" {
  vpc_id = aws_vpc.vpc.id
  ingress {
    description      = "Allow all inbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    description      = "Allow all outboud traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


resource "aws_security_group" "ec2_endpoint" {
  name   = "ec2-endpoint"
  vpc_id = aws_vpc.vpc.id
}
resource "aws_security_group" "ecr_endpoint" {
  name   = "ecr-endpoint"
  vpc_id = aws_vpc.vpc.id
}


resource "aws_security_group_rule" "ec2_443" {
  security_group_id = aws_security_group.ec2_endpoint.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = local.subnets_cidrs
}
resource "aws_security_group_rule" "ecr_443" {
  security_group_id = aws_security_group.ecr_endpoint.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = local.subnets_cidrs
}


resource "aws_vpc_endpoint" "ec2" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.us-east-1.ec2"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.vpc_private_subnets[*].id

  security_group_ids = [
    aws_security_group.ec2_endpoint.id,
  ]
}
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.us-east-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.vpc_private_subnets[*].id

  security_group_ids = [
    aws_security_group.ecr_endpoint.id,
  ]
}
resource "aws_vpc_endpoint" "ecr_drk" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.us-east-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.vpc_private_subnets[*].id

  security_group_ids = [
    aws_security_group.ecr_endpoint.id,
  ]
}
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.vpc_private_route_table.id]
}
