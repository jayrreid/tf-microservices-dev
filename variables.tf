//--------------------------------------------------------------------
// Variables
variable "region" {
  default = "us-west-2"
}

variable "eks_cluster_name" {
  description = "cluster name"
}

variable "gremlin_secret_teamID" {
  description = "gremlin_secret_teamID"
}

variable "gremlin_secret_teamSecret" {
  description = "gremlin_secret_teamSecret"
}

variable "vpc1_vpc_name" {}

variable "vpc1_cidr" {
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
