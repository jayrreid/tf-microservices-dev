provider "aws" {
  region  = var.region
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
  subnets = ["module.vpc1.master_subnet", "module.vpc1.worker_node_subnet"]
  vpc_id = module.vpc1.vpc_id
}
