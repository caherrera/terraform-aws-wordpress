### Deploys WordPress according to AWS best practice
### Deploys: EC2 instance, ELB, ASG, RDS, EFS and CloudFront(future)

# To SSH to your EC2 instance use its public ip make sure to set admin_vm_ip to your bastion/jumpbox

# Bitnami default values on the AMI, used while creating RDS to mirror settings on local mySql
# Could have worked on changing it, but there is justification.
# --------------------------------------------------------

### Variables
locals {
  db_name     = var.db_name
  db_username = var.db_username
  asg_name    = join("-", [
    "wp",
    var.sitename,
    "asg"])
  elb_name    = join("-", [
    "wp",
    var.sitename,
    "elb"])
  lc_name     = join("-", [
    "wp",
    var.sitename,
    "lc"])
}

# --------------------------------------------------------

### Deploy ELB pointing to EC2
resource "aws_elb" "wordpress" {
  name                        = local.elb_name
  instances                   = [
    aws_instance.wordpress.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 300
  connection_draining         = true
  connection_draining_timeout = 300
  security_groups             = [
    aws_security_group.wordpress_elb.id]
  subnets                     = [
    data.aws_subnet.wordpress.id]

  access_logs {
    bucket        = aws_s3_bucket.elb_logs.bucket
    bucket_prefix = ""
    interval      = 60
  }

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  # ELB with SSL certificate configured

  # listener {
  #   instance_port      = 443
  #   instance_protocol  = "http"
  #   lb_port            = 443
  #   lb_protocol        = "https"
  #   ssl_certificate_id = "${var.elb_ssl_cert}"
  # }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  tags = var.tags
}

# --------------------------------------------------------
### Deploy automatic scaling group for EC2 instance

module "asg" {
  name    = "wordpress_asg"
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 3.0"

  lc_name       = local.lc_name
  image_id      = data.aws_ami.wordpress.id
  instance_type = "t2.micro"

  security_groups = [
    aws_security_group.wordpress.id,
  ]

  ebs_block_device = [
    {
      device_name           = "/dev/xvdz"
      volume_type           = "gp2"
      volume_size           = "50"
      delete_on_termination = true
    },
  ]

  root_block_device = [
    {
      volume_size = "50"
      volume_type = "gp2"
    },
  ]

  asg_name = local.asg_name

  vpc_zone_identifier       = [
    aws_instance.wordpress.subnet_id]
  health_check_type         = "EC2"
  min_size                  = 1
  max_size                  = 4
  desired_capacity          = 1
  wait_for_capacity_timeout = 0

}
