data "aws_ami" "wordpress" {
  most_recent = true
  owners      = ["979382823631"]

  filter {
    name   = "name"
    values = ["*bitnami-wordpresspro-5.2*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Data source to get the Account ID of the AWS Elastic Load Balancing Service Account -
# in a given region for the purpose of whitelisting in S3 bucket policy.
data "aws_elb_service_account" "main" {}
data "aws_caller_identity" "current" {}


resource "random_string" "short" {
  length  = 8
  upper   = false
  special = false
}