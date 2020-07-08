
provider "aws" {
  version = ">= 2.28.1"
  region  = var.region
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
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



resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = module.vpc1.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/16",
    ]
  }
}

module "eks" {
  source  = "app.terraform.io/koinonia/eks/aws"
  version = "1.0.0"

  cluster_name = "${var.eks_cluster_name}"
  subnets = flatten([module.vpc1.master_subnet, module.vpc1.worker_node_subnet])
  vpc_id = module.vpc1.vpc_id

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t2.small"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 2
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },
    {
      name                          = "worker-group-2"
      instance_type                 = "t2.medium"
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      asg_desired_capacity          = 2
    },
  ]

}
