# Dynamically calling the latest ubuntu ami
data "aws_ami" "ubuntu" {

  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

# This is dynamically calling the db secrets we based to the secrets manager, and use in creating the DB
data "aws_secretsmanager_secret_version" "current" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  depends_on = [aws_secretsmanager_secret_version.db_secret_version]
}