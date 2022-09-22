# ------------------------------------ TF ------------------------------------ #
#                                                                              #
terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.30.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.21.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.13.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.6.0"
    }
  }

  required_version = ">= 1.2.9"
}
#                                                                              #
# ------------------------------------ /TF ----------------------------------- #




# ------------------------------------ EKS ----------------------------------- #
#                                                                              #
module "aws_eks_cluster" {
  source = "./modules/aws-eks-cluster"

  cluster_name = var.eks_cluster_name

  aws_region             = var.aws_region
  aws_availability_zones = var.aws_availability_zones

  ssh_access_keys = var.eks_ssh_access_keys

  vpc_cidr_block      = var.eks_vpc_cidr_block
  vpc_public_subnets  = var.eks_vpc_public_subnets
  vpc_private_subnets = var.eks_vpc_private_subnets

  resources_encryption  = var.eks_resources_encryption
  encryption_components = var.eks_encryption_components

  enable_logs          = var.eks_enable_logs
  log_retention_period = var.eks_log_retention_period
  log_components       = var.eks_log_components

  public_worker_node_group  = var.eks_public_worker_node_group
  private_worker_node_group = var.eks_private_worker_node_group
}
#                                                                              #
# ------------------------------------ /EKS ---------------------------------- #




# ------------------------------------ ECR ----------------------------------- #
#                                                                              #
module "aws_ecr_repository" {
  source          = "./modules/aws-ecr-repository"
  repository_name = var.ecr_repository_name
  force_delete    = var.ecr_repository_force_delete
}

resource "docker_registry_image" "hivemind_hiring_challange" {
  name = "${ module.aws_ecr_repository.aws_ecr_repository_url }:latest"

  build {
    context = ".."
    dockerfile = "Dockerfile"
  }

  depends_on = [
    module.aws_ecr_repository
  ]
}
#                                                                              #
# ------------------------------------ /ECR ---------------------------------- #




# --------------------------------- NLB & ALB -------------------------------- #
#                                                                              #

# TODO: As of now if the aws_load_balancer_controller_namespace variable is set
# to something different from kube-system deployment will fail as the namespace is not
# created!
resource "aws_iam_role" "aws_eks_lb_controller" {
  name = "aws_eks_lb_controller"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action : "sts:AssumeRoleWithWebIdentity"
        Principal = {
          Federated = format(
            "arn:aws:iam::%s:oidc-provider/oidc.eks.%s.amazonaws.com/id/%s",
            data.aws_caller_identity.current.account_id,
            data.aws_region.current.name,
            replace(module.aws_eks_cluster.eks_oidc_issuer, "https://", "oidc-provider/")
          )
        }
        Condition = {
          StringEquals = {
            format(
              "oidc.eks.%s.amazonaws.com/id/%s:aud",
              data.aws_region.current.name,
              trimprefix(module.aws_eks_cluster.eks_oidc_issuer, "https://")
            ) = "sts.amazonaws.com",
            format(
              "oidc.eks.%s.amazonaws.com/id/%s:sub",
              data.aws_region.current.name,
              trimprefix(module.aws_eks_cluster.eks_oidc_issuer, "https://")
            ) = "system:serviceaccount:${var.aws_load_balancer_controller_namespace}:${var.aws_load_balancer_controller_sa_name}"
          }
        }
        Effect = "Allow"
      },
    ]
  })
}

resource "aws_iam_policy" "aws_eks_lb_controller" {
  name = "AWSLoadBalancerControllerIAMPolicy"
  description = "Kubernetes Load balancer controller's AWS IAM Policy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceLinkedRole"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": "elasticloadbalancing.amazonaws.com"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeAddresses",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeVpcs",
                "ec2:DescribeVpcPeeringConnections",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeInstances",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeTags",
                "ec2:GetCoipPoolUsage",
                "ec2:DescribeCoipPools",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeListenerCertificates",
                "elasticloadbalancing:DescribeSSLPolicies",
                "elasticloadbalancing:DescribeRules",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetGroupAttributes",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:DescribeTags"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cognito-idp:DescribeUserPoolClient",
                "acm:ListCertificates",
                "acm:DescribeCertificate",
                "iam:ListServerCertificates",
                "iam:GetServerCertificate",
                "waf-regional:GetWebACL",
                "waf-regional:GetWebACLForResource",
                "waf-regional:AssociateWebACL",
                "waf-regional:DisassociateWebACL",
                "wafv2:GetWebACL",
                "wafv2:GetWebACLForResource",
                "wafv2:AssociateWebACL",
                "wafv2:DisassociateWebACL",
                "shield:GetSubscriptionState",
                "shield:DescribeProtection",
                "shield:CreateProtection",
                "shield:DeleteProtection"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateSecurityGroup"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags"
            ],
            "Resource": "arn:aws:ec2:*:*:security-group/*",
            "Condition": {
                "StringEquals": {
                    "ec2:CreateAction": "CreateSecurityGroup"
                },
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags",
                "ec2:DeleteTags"
            ],
            "Resource": "arn:aws:ec2:*:*:security-group/*",
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "true",
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:DeleteSecurityGroup"
            ],
            "Resource": "*",
            "Condition": {
                "Null": {
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateTargetGroup"
            ],
            "Resource": "*",
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:CreateRule",
                "elasticloadbalancing:DeleteRule"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:RemoveTags"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
            ],
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "true",
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:RemoveTags"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
                "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
                "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
                "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:SetIpAddressType",
                "elasticloadbalancing:SetSecurityGroups",
                "elasticloadbalancing:SetSubnets",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:ModifyTargetGroupAttributes",
                "elasticloadbalancing:DeleteTargetGroup"
            ],
            "Resource": "*",
            "Condition": {
                "Null": {
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:DeregisterTargets"
            ],
            "Resource": "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:SetWebAcl",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:AddListenerCertificates",
                "elasticloadbalancing:RemoveListenerCertificates",
                "elasticloadbalancing:ModifyRule"
            ],
            "Resource": "*"
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "aws_eks_lb_controller" {
  role = aws_iam_role.aws_eks_lb_controller.name
  policy_arn = aws_iam_policy.aws_eks_lb_controller.arn
}

resource "kubernetes_service_account" "aws_load_balancer_controller" {
  metadata {
    name      = var.aws_load_balancer_controller_sa_name
    namespace = var.aws_load_balancer_controller_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = format(
        "arn:aws:iam::%s:role/%s",
        data.aws_caller_identity.current.account_id,
        aws_iam_role.aws_eks_lb_controller.name
      )
    }
  }

  depends_on = [
    module.aws_eks_cluster,
  ]
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = var.aws_load_balancer_controller_namespace
  values = [
    templatefile(
      "${path.module}/templates/helm/aws_load_balancer_controller.yml.tftpl",
      {
        cluster_name     = var.eks_cluster_name,
        sa_name          = kubernetes_service_account.aws_load_balancer_controller.metadata[0].name,
        image_repository = "602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon/aws-load-balancer-controller",
      }
    )
  ]
  depends_on = [
    kubernetes_service_account.aws_load_balancer_controller
  ]
}
#                                                                              #
# --------------------------------- /NLB & ALB ------------------------------- #




# --------------------------------- MONITORING ------------------------------- #
#
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }

  depends_on = [
    module.aws_eks_cluster
  ]
}

resource "helm_release" "aws_for_fluent_bit" {
  name       = "test-release"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"
  namespace  = "monitoring"
  values = [
    "${file("./templates/helm/fluent_bit.yml")}"
  ]

  depends_on = [
    kubernetes_namespace.monitoring
  ]
}
#                                                                              #
# --------------------------------- /MONITORING ------------------------------ #



# ------------------------------------- APP ---------------------------------- #
#
# TODO: Since I was not able to use the docker provider in my local environment
# (see README.md Known bugs #1) I wasn't able to test the following snippet that
# should deploy the application chart to the cluster.

resource "helm_release" "app" {
  name       = "app"
  repository = local.aws_ecr_registry_url
  chart      = "${ module.aws_ecr_repository.aws_ecr_repository_url }:latest"
  namespace  = "default"
  values = [
    templatefile(
      "${path.module}/templates/helm/app.yml.tftpl",
      {
        image_repository     = module.aws_ecr_repository.aws_ecr_repository_url,
        image_name           = local.aws_ecr_registry_url,
      }
    )
  ]
  depends_on = [
    helm_release.aws_load_balancer_controller
  ]
}
#                                                                              #
# ------------------------------------- /APP --------------------------------- #









# resource "helm_release" "deployments" {
#   count = length(var.helm_charts)
#
#   name = var.helm_charts[count.index].name
#   repository = var.helm_charts[count.index].repository
#   chart = var.helm_charts[count.index].chart
#   namespace = var.helm_charts[count.index].namespace
#   values = [
#     "${file(var.helm_charts[count.index].values_file)}"
#   ]
#
#   depends_on = [
#     kubernetes_namespace.monitoring
#   ]
# }
