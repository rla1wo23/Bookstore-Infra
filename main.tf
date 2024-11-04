resource "random_id" "frontend_bucket_suffix" {
  byte_length = 4
}

module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.30.1"

  cluster_name    = var.eks_cluster_name
  cluster_version = var.cluster_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.public_subnet_ids

  eks_managed_node_groups = {
    default = {
      name             = "default"
      desired_capacity = var.desired_capacity
      min_size         = var.min_size
      max_size         = var.max_size
      instance_types   = [var.node_instance_type]
    }
  }

  tags = {
    Name = var.eks_cluster_name
  }
}

module "rds" {
  source                = "./modules/rds"
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  db_instance_class     = var.db_instance_class
  vpc_security_group_id = module.vpc.default_security_group_id
  subnet_ids            = module.vpc.private_subnet_ids
}

module "s3" {
  source = "./modules/s3"
  frontend_bucket_name = var.frontend_bucket_name != "" ? var.frontend_bucket_name : "bookstore-frontend-${random_id.frontend_bucket_suffix.hex}"
}
