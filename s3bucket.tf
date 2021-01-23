# WordPress content S3 bucket IAM role, policy and profile
# Attached to EC2 instances
resource "aws_iam_instance_profile" "wordpress" {
  name = "WordPressS3Profile"
  role = aws_iam_role.wordpress.name
}

resource "aws_iam_role" "wordpress" {
  name = "WordPressS3Role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]

}
EOF

  tags = var.tags
}

resource "aws_iam_role_policy" "wordpress" {
  name = "WordPressS3Policy"
  role = aws_iam_role.wordpress.id

  policy = <<EOF
{
	"Version": "2012-10-17",

	"Statement": [
	{
		"Effect": "Allow",
		"Action": [
			"s3:CreateBucket",
			"s3:DeleteObject",
			"s3:Put*",
			"s3:Get*",
			"s3:List*"
		],
		"Resource": [
			"${aws_s3_bucket.wordpress.arn}",
			"${aws_s3_bucket.wordpress.arn}/*"
		]
	}
	]
}
EOF

}

# --------------------------------------------------------
# S3 Buckets

locals {
  s3_content = "wordpress-content-${data.aws_caller_identity.current.account_id}-${random_string.short.result}"
  s3_logs    = "wordpress-elblogs-${data.aws_caller_identity.current.account_id}-${random_string.short.result}"
}

resource "aws_s3_bucket" "wordpress" {
  acl           = "private"
  bucket        = local.s3_content
  force_destroy = true

  region = var.region
  tags   = var.tags
}

resource "aws_s3_bucket" "elb_logs" {
  acl           = "private"
  bucket        = local.s3_logs
  force_destroy = true

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "wordpress-buck-policy",
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${local.s3_logs}/*",
      "Principal": {
        "AWS": [
           "${data.aws_elb_service_account.main.arn}"
        ]
      }
    }
  ]
}
POLICY

  region = var.region
  tags   = var.tags
}
