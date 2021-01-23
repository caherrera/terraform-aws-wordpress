resource "aws_db_instance" "wordpress" {
  allocated_storage    = 10
  identifier           = "wordpress-${data.aws_caller_identity.current.account_id}-${random_string.short.result}"
  storage_type         = "gp2"
  engine               = "mariadb"
  engine_version       = "10.2"
  instance_class       = var.rds_instance_type
  name                 = local.db_name
  username             = local.db_username
  password             = var.db_password
  parameter_group_name = "default.mariadb10.2"
  db_subnet_group_name = aws_db_subnet_group.wordpress.id
  skip_final_snapshot  = true

  vpc_security_group_ids = [
    aws_security_group.wordpress_db.id,
  ]

  tags = var.tags
}
