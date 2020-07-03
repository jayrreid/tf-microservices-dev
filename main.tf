
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

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.11"
}

resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
  }
}

resource "helm_release" "istio_init" {
  name       = "istio-init"
  repository = "https://storage.googleapis.com/istio-release/releases/1.5.4/charts/"
  chart      = "istio-init"
  version    = "1.5.4"
  namespace  = "${kubernetes_namespace.istio.metadata.0.name}"

}

/* even though depends_on is configured, this will fail because the above CRDs
* have yet to propagate to the api server. the only solution thus far is to introduce
* a delay within the terraform config. */
resource "helm_release" "istio" {
  depends_on = ["helm_release.istio_init"]
  name       = "istio"
  repository = "https://storage.googleapis.com/istio-release/releases/1.5.4/charts/"
  version    = "1.5.4"
  chart      = "istio"
  namespace  = "kubernetes_namespace.istio.metadata.0.name"
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
