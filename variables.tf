variable "s3_bucket_name" {}
variable "public_subnets" {}
variable "private_subnets" {}
variable "azs" {}
variable "internet_gateway_id" {}
variable "vpc_id" {}
variable "cluster_name" {}

variable "region" {
  default = "eu-west-2"
}

variable "private_subnet_suffix" {
  description = "Suffix to append to private subnets name"
  type        = string
  default     = "private"
}

locals {
  cluster_name        = var.cluster_name
  vpc_id              = var.vpc_id
  internet_gateway_id = var.internet_gateway_id
  azs                 = var.azs
  private_subnets     = var.public_subnets
  public_subnets      = var.public_subnets

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
  s3_bucket_name = var.s3_bucket_name

  cluster_oidc_issuer_endpoint = try(regex("^(https://)(.*)", module.eks.cluster_oidc_issuer_url)[1], "localhost")

}

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
