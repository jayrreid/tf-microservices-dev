terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  version = ">= 2.28.1"
  region  = var.region
}

provider "random" {
  version = "~> 2.1"
}

provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.11"
}

data "aws_availability_zones" "available" {
}

locals {
  cluster_name = "test-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

//--------------------------------------------------------------------
// Modules

module "vpc1" {
  source  = "app.terraform.io/koinonia/vpc1/aws"
  version = "1.0.0"

  cidr = "${var.vpc1_cidr}"
  cluster_name = "${var.eks_cluster_name}"
  master_subnet_cidr = "${var.vpc1_master_subnet_cidr}"
  private_subnet_cidr = "${var.vpc1_private_subnet_cidr}"
  public_subnet_cidr = "${var.vpc1_public_subnet_cidr}"
  vpc_name = "${var.vpc1_vpc_name}"
  worker_subnet_cidr = "${var.vpc1_worker_subnet_cidr}"
}


module "eks" {
  source  = "app.terraform.io/koinonia/eks/aws"
  version = "1.0.0"

  cluster_name = "${var.eks_cluster_name}"
  subnets = flatten([module.vpc1.master_subnet, module.vpc1.worker_node_subnet])
  vpc_id = module.vpc1.vpc_id
}
