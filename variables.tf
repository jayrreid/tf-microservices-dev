//--------------------------------------------------------------------
// Variables
variable "eks_permissions_boundary" {
  description ="permission boundary attached"
}

variable "eks_vpc_id" {
  description = "Description: VPC where the cluster and workers will be deployed."
}

variable "eks_cluster_name" {
  description = "cluster name"
}


variable "vpc1_vpc_name" {}

variable "cidr" {
  description = "The CIDR block for the VPC."
}

#subnet variable
variable "vpc1_master_subnet_cidr" {
  type        = list(string)
  description = "CIDR for master subnet"
  default     = []
}

variable "vpc1_worker_subnet_cidr" {
  type        = list(string)
  description = "CIDR for worker subnet"
  default     = []
}

variable "vpc1_public_subnet_cidr" {
  description = "Kubernetes Public CIDR"
  type        = list(string)
}

variable "vpc1_private_subnet_cidr" {
  type        = list(string)
  description = "Kubernetes Private CIDR"
  default     = []
}
