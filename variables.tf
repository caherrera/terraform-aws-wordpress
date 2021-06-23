#--------------------------------------------------------
### Required

variable "subnet_id" {
  description = "Specifies the subnet to provision resources to."
  type        = string
}

variable "subnet_2_id" {
  description = "Specifies the secondary subnet to provision resources to."
  type        = string
}

variable "jumpbox_ip" {
  description = "The jumpbox ip address used to administer the EC2 instance (For SSH communication)."
  type        = string
}

variable "db_password" {
  description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file."
  type        = string
}

variable "ec2_public_key" {
  description = "The public key to use for SSH authentication with the instances"
  type        = string
}

variable "ec2_private_key" {
  description = "The public key to use for SSH authentication with the instances"
  type        = string
}

#--------------------------------------------------------
### Optionals

variable "sitename" {
  type    = string
  default = "wordpress"
}

variable "db_username" {
  description = "User for the master DB user. Note that this may show up in logs, and it will be stored in the state file."
  type        = string
  default     = "bn_wordpress"
}

variable "db_name" {
  description = "Name for the master DB user. Note that this may show up in logs, and it will be stored in the state file."
  type        = string
  default     = "bitnami_wordpress"
}


variable "availability_zone" {
  description = "Main availability zone for resources with no high availability."
  type        = string
  default     = "us-east-1a"
}

variable "availability_zones" {
  description = "Availability zones for highly available resources."
  type        = list(string)

  default = [
    "us-east-1a",
    "us-east-1d",
  ]
}

variable "elb_ssl_cert" {
  description = "If using SSL certificate on ELB, provide certificate ARN."
  type        = string
  default     = ""
}

variable "ec2_instance_type" {
  description = "The type of instance to start. Updates to this field will trigger a stop/start of the EC2 instance."
  type        = string
  default     = "t2.micro"
}

variable "rds_instance_type" {
  description = "(Required) The instance type of the RDS instance."
  type        = string
  default     = "db.t2.micro"
}

variable "tags" {
  description = "Specifies object tags key and value."
  type        = map(string)
  default     = {}
}

variable "region" {
  type    = string
  default = "sa-east-1"
}