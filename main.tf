
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

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.0.3"
  cluster_name    = local.cluster_name
  cluster_version = "1.20"
  subnets         = aws_subnet.private.*.id

  enable_irsa = true
  tags = {
    Environment                                       = "opsfleet-demo"
    "k8s.io/cluster-autoscaler/enabled"               = "true"
    "k8s.io/cluster-autoscaler/${local.cluster_name}" = ""
  }
  write_kubeconfig = true

  vpc_id = local.vpc_id

  map_roles = [
    {
      rolearn  = module.eksadmin.role_arn
      username = "eksadmin"
      groups   = ["system:masters"]
    }
  ]

  worker_groups = [
    {
      name                 = "worker-group-1"
      instance_type        = "m5.xlarge"
      asg_desired_capacity = 1
      asg_max_size         = 10
      asg_min_size         = 1
      root_volume_type     = "gp2"
      autoscaling_enabled  = true
      public_ip            = false
      bootstrap_extra_args = "--enable-docker-bridge true"
    }
  ]
}
