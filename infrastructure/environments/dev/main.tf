provider "aws" {
  region = var.aws_region
  default_tags {
    tags = var.tags
  }
}

# In a real environment, the backend would be created first manually or via a separate bootstrap module.
# module "backend" { ... }

module "vpc" {
  source               = "../../modules/vpc"
  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  azs_count            = 3
  private_subnets_cidr = var.private_subnets_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  tags                 = var.tags
}

module "eks" {
  source             = "../../modules/eks"
  project_name       = var.project_name
  environment        = var.environment
  cluster_version    = "1.28"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  node_groups = {
    general = {
      name           = "general-node-group"
      instance_types = ["t3.large"]
      min_size       = 2
      max_size       = 5
      desired_size   = 2
      capacity_type  = "SPOT"
    }
  }

  tags = var.tags
}

module "ecr_frontend" {
  source          = "../../modules/ecr"
  project_name    = var.project_name
  repository_name = "frontend"
  tags            = var.tags
}

module "ecr_backend" {
  source          = "../../modules/ecr"
  project_name    = var.project_name
  repository_name = "backend"
  tags            = var.tags
}

resource "aws_db_subnet_group" "default" {
  name       = "${var.project_name}-db-subnet-group-${var.environment}"
  subnet_ids = module.vpc.private_subnets
  tags       = var.tags
}

module "rds" {
  source                        = "../../modules/rds"
  project_name                  = var.project_name
  environment                   = var.environment
  vpc_id                        = module.vpc.vpc_id
  db_subnet_group_name          = aws_db_subnet_group.default.name
  eks_cluster_security_group_id = module.eks.node_security_group_id
  instance_class                = var.db_instance_class
  db_name                       = var.db_name
  db_username                   = var.db_username
  tags                          = var.tags
}

module "redis" {
  source                        = "../../modules/redis"
  project_name                  = var.project_name
  environment                   = var.environment
  vpc_id                        = module.vpc.vpc_id
  private_subnet_ids            = module.vpc.private_subnets
  eks_cluster_security_group_id = module.eks.node_security_group_id
  node_type                     = var.redis_node_type
  tags                          = var.tags
}

module "secrets" {
  source       = "../../modules/secrets"
  project_name = var.project_name
  environment  = var.environment
  kms_key_id   = module.eks.kms_key_id # I need to ensure EKS module outputs kms_key_id
  db_username  = var.db_username
  db_password  = module.rds.db_instance_password
  db_host      = module.rds.db_instance_endpoint
  db_name      = var.db_name
  tags         = var.tags
}
