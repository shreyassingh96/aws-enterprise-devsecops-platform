terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0.0"

  name = "${var.project_name}-vpc-${var.environment}"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, var.azs_count)
  private_subnets = var.private_subnets_cidr
  public_subnets  = var.public_subnets_cidr

  enable_nat_gateway     = true
  single_nat_gateway     = var.environment == "prod" ? false : true
  one_nat_gateway_per_az = var.environment == "prod" ? true : false
  enable_dns_hostnames   = true
  enable_dns_support     = true

  # Tagging for EKS
  public_subnet_tags = {
    "kubernetes.io/role/elb"                                      = "1"
    "kubernetes.io/cluster/${var.project_name}-eks-${var.environment}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"                             = "1"
    "kubernetes.io/cluster/${var.project_name}-eks-${var.environment}" = "shared"
  }

  tags = var.tags
}
