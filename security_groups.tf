# This is a security group for the ec2 instances in the private subnet
resource "aws_security_group" "Webserver_security_group" {
  name        = "Web Server Security Group"
  description = "Enable HTTP/HTTPS ports"
  vpc_id      = aws_ssm_parameter.vpc-id.value

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_security_group.id]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_security_group.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Webserver Security Group"
  }
}

# Security Group for the Application Load Balancer
resource "aws_security_group" "alb_security_group" {
  name        = "ALB Security Group"
  description = "Allow HTTP and HTTPS ports"
  vpc_id      = aws_ssm_parameter.vpc-id.value

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Alb Security Group"
  }
}


# Security Group for the database in the private DB subnet, to allow access from the EC2 instances in the private subnet
resource "aws_security_group" "Database_security_group" {
  name        = "Database server Security Group"
  description = "Enable MYSQL access on port 3306"
  vpc_id      = aws_ssm_parameter.vpc-id.value

  ingress {
    description     = "MYSQL Access"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.Webserver_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Database Security Group"
  }
}


# Security Group for our Bastion Host, for ssh access into out instances in the private subnet
resource "aws_security_group" "ssh_security_group" {
  name        = "SSH Access"
  description = "Enable SSH on port 22"
  vpc_id      = aws_ssm_parameter.vpc-id.value

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Application Security Group"
  }
}