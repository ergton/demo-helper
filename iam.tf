module "eksadmin" {
  source                  = "./modules/terraform-aws-iam-roles"
  create_instance_profile = true
  role                    = "eksadmin"
  policy_file             = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ec2AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  policy_arn = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
  ]
}
