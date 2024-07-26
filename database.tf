# Databse Subnet, in the private subnet we created for the private subent
resource "random_password" "db-password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_db_subnet_group" "database-subnet" {
  name       = "database-subnets"
  subnet_ids = [aws_ssm_parameter.Private-DB-1.value, aws_ssm_parameter.Private-DB-2.value]

  tags = {
    Name = "My DB subnet group"
  }
}

# AWS secrets manager configuration
resource "aws_secretsmanager_secret" "db_credentials" {
  name = "success_db_credentials"
}

# Aws secret manager credential, passed to the secret manager directory
resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db-username
    password = random_password.db-password.result
  })
}

# This saves the data in a JSON formet, for easy access by the DB
locals {
  db_credentials = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)

  depends_on = [aws_secretsmanager_secret_version.db_secret_version]
}

#Database configuration instance
resource "aws_db_instance" "database-instance" {
  allocated_storage    = 10
  db_name              = "sqldb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = var.database-instance-class
  username             = local.db_credentials.username
  password             = local.db_credentials.password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  availability_zone    = var.availability-1
  db_subnet_group_name = aws_db_subnet_group.database-subnet.name
  # multi_az               = true
  vpc_security_group_ids = [aws_security_group.Database_security_group.id]
}