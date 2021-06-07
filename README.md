
#### The current repository requires the following:
- an existing VPC
- an existing Internet Gateway
- aws key and secret to access the AWS resources

#### What will be created
- one NAT Gateway with an Elastic IP attached
- private subnets attached to the NAT Gateway
- public subnets attached to the Ingress Gateway
- one routing table for the private subnets
- one routing table for the public subnets
- EKS cluster attached to the IAM AWS account as an identity provider
- an `eksadmin` IAM role (Please note that this will need to be updated with the users allowed to assume)
- a test IAM role to be assumed from Kubernetes namespace `app1` by a serviceAccount called `app1`
- an s3 bucket to which the serviceAccount `app1` will have full access

#### Deployment steps

- from the available VPC create an `external_vars.tfvars` with the following variables. A subnet calculator can be found here https://www.site24x7.com/tools/ipv4-subnetcalculator.html
```
public_subnets      = ["172.31.53.x/xx", "172.31.54.x/xx", "172.31.55.x/xx"]
private_subnets     = ["172.31.50.x/xx", "172.31.51.x/xx", "172.31.52.xx/xx"]
azs                 = ["xx-west-2a", "xx-west-2b", "xx-west-2c"]
internet_gateway_id = "igw-xxxxxxxx"
vpc_id              = "vpc-xxxxxxxx"
cluster_name        = "opsfleet-eks"
s3_bucket_name      = "app1-123456789"
```
- apply terraform using the commands
```
terraform init
terraform plan -var-file external_vars.tfvar
terraform apply -var-file external_vars.tfvar
```
- any applications deployed in `app1` namespace with a serviceAccount `app1` attached will be able to access the s3 bucket `s3_bucket_name` mentioned above. Below can be found an example. Replace the AWS_ACCOUNT_ID from the manifest with the actual AWS account id
```
apiVersion: v1
kind: Namespace
metadata:
    name: app1
```
```
apiVersion: v1
kind: ServiceAccount
metadata:
    name: app1
    namespace: app1
    annotations:
      eks.amazonaws.com/role-arn: arn:aws:iam::AWS_ACCOUNT_ID:role/app1
```
```
metadata:
  labels:
    name: app-name
  name: app-name
  namespace: app1
spec:
    spec:
      serviceAccount: app1
      containers:
      - name: .....
```
