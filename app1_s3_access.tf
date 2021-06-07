data "aws_caller_identity" "current" {}


data "aws_iam_policy_document" "app1" {
  statement {
    sid = "AllowS3BucketAccess"
    actions = [
      "s3:*",
    ]
    resources = [
      "arn:aws:s3:::${local.s3_bucket_name}",
      "arn:aws:s3:::${local.s3_bucket_name}/*"
    ]
  }
}

data "aws_iam_policy_document" "app1_irsa" {
  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]
    principals {
      type = "Federated"
      identifiers = [
        module.eks.oidc_provider_arn
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.cluster_oidc_issuer_endpoint}:sub"

      values = [
        "system:serviceaccount:app1:app1"
      ]
    }
  }
}

resource "aws_iam_policy" "app1" {
  name   = "app1"
  policy = data.aws_iam_policy_document.app1.json
}

resource "aws_iam_role" "app1" {
  name               = "app1"
  assume_role_policy = data.aws_iam_policy_document.app1_irsa.json
  tags = {
    terraform = true
  }
}

resource "aws_iam_role_policy_attachment" "app1" {
  role       = aws_iam_role.app1.name
  policy_arn = aws_iam_policy.app1.arn
}
