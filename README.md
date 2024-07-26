# Building a Secure and Scalable Infrastructure on AWS with Terraform
## Introduction
In this blog post, I'll walk you through the process of building a secure and scalable infrastructure on AWS using Terraform. The infrastructure setup includes a Virtual Private Cloud (VPC) with public and private subnets, security groups, an Internet Gateway, a NAT Gateway, an Application Load Balancer, and an RDS instance for a MySQL database. This guide will help you understand the components involved and how they fit together to create a robust and flexible cloud environment.

## Prerequisites
Before we begin, make sure you have the following:

* An AWS account with appropriate permissions to create resources.
* Terraform installed on your local machine.
* A basic understanding of AWS services and Terraform.

## Terraform Code Breakdown
### VPC Setup
First, we define our VPC, which is the network container for our infrastructure.

```
resource "aws_vpc" "vpc-01" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name}-gyenoch-VPC"
  }
}
```

## Subnets
Next, we create public and private subnets within the VPC. Public subnets will host resources that need internet access, while private subnets will host resources that should not be directly accessible from the internet.

```
  resource "aws_subnet" "pub-sn-1" {
  vpc_id                  = aws_ssm_parameter.vpc-id.value
  cidr_block              = var.public_subnet_01_cidr
  availability_zone       = var.availability-1
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-Public-subnet-1"
  }
}



resource "aws_subnet" "pub-sn-2" {
  vpc_id                  = aws_ssm_parameter.vpc-id.value
  cidr_block              = var.public_subnet_02_cidr
  availability_zone       = var.availability-2
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-Public-subnet-2"
  }
}
```

## Private Subnets
Private subnets are defined similarly but do not map public IPs on launch.


```
resource "aws_subnet" "pri-sn-1" {
  vpc_id                  = aws_ssm_parameter.vpc-id.value
  cidr_block              = var.private_subnet_01_cidr
  availability_zone       = var.availability-1
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name}-Private-subnet-1 | App Tier"
  }
}

resource "aws_subnet" "pri-sn-2" {
  vpc_id                  = aws_ssm_parameter.vpc-id.value
  cidr_block              = var.private-subent-02-cidr
  availability_zone       = var.availability-2
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name}-Private-subnet-2 | App tier"
  }
}

```

## Security Groups
Security groups control inbound and outbound traffic for resources. Here, we create a security group for web servers and another for the database.

```
resource "aws_security_group" "Webserver_security_group" {
  name        = "Web Server Security Group"
  description = "Enable HTTP/HTTPS ports"
  vpc_id      = aws_ssm_parameter.vpc-id.value

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    security_groups = [aws_security_group.alb_security_group.id]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    security_groups = [aws_security_group.alb_security_group.id]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
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
```

## SSM Parameters
SSM parameters store values for VPC and subnet IDs, making it easier to reference them in other parts of the configuration.

```
resource "aws_ssm_parameter" "vpc-id" {
  name = "${var.name}-vpcID"
  value = aws_vpc.vpc-01.id
  type = "String"
  depends_on = [ aws_vpc.vpc-01 ]
}

resource "aws_ssm_parameter" "pub-sn-1" {
  type = "String"
  name = "${var.name}-Public-Subnet-1"
  value = aws_subnet.pub-sn-1.id
  depends_on = [ aws_subnet.pub-sn-1 ]
}
```

## Internet Gateway and NAT Gateway
The Internet Gateway allows resources in public subnets to access the internet, while the NAT Gateway allows resources in private subnets to access the internet without being exposed.

```
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_ssm_parameter.vpc-id.value

  tags = {
    Name = "My-IGW"
  }
}

resource "aws_eip" "eip-nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.eip-nat.id
  subnet_id     = aws_ssm_parameter.pub-sn-2.value

  tags = {
    Name = "Nat GW"
  }
}
```

## Route Tables
Route tables control traffic routing. We create a public route table for the public subnets and a private route table for the private subnets.

```
resource "aws_route_table" "public-route" {
  vpc_id = aws_ssm_parameter.vpc-id.value

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public-route-Table"
  }
}

resource "aws_route_table_association" "Public-Subnet-1" {
  subnet_id      = aws_ssm_parameter.pub-sn-1.value
  route_table_id = aws_route_table.public-route.id
}

resource "aws_route_table" "private-route" {
  vpc_id = aws_ssm_parameter.vpc-id.value

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }

  tags = {
    Name = "Private-route-Table"
  }
}

resource "aws_route_table_association" "nat_route_1" {
  subnet_id      = aws_ssm_parameter.pri-sn-1.value
  route_table_id = aws_route_table.private-route.id
}
```

## Load Balancer and Autoscaling
We set up an Application Load Balancer (ALB) to distribute traffic and an autoscaling group to manage the number of EC2 instances based on demand.

```
resource "aws_lb" "application-load-balancer" {
  name                       = "web-external-load-balancer"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_security_group.id]
  subnets                    = [aws_ssm_parameter.pub-sn-1.value, aws_ssm_parameter.pub-sn-2.value]
  enable_deletion_protection = false

  tags = {
    Name = "${var.name}-var.lb"
  }
}

resource "aws_autoscaling_group" "asg-1" {
  vpc_zone_identifier = [ aws_ssm_parameter.pri-sn-1.value, aws_ssm_parameter.pri-sn-2.value ]
  desired_capacity   = 2
  min_size           = 1
  max_size           = 5

  launch_template {
    id      = aws_launch_template.auto-scaling-group.id
    version = "$Latest"
  }
}
```

## Database Setup
We configure an RDS instance for our MySQL database, ensuring that the database is in a private subnet for security.

```
resource "aws_db_instance" "database-instance" {
  allocated_storage      = 10
  db_name                = "sqldb"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.database-instance-class
  username               = local.db_credentials.username
  password               = local.db_credentials.password
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  availability_zone      = your availability zone
  db_subnet_group_name   = aws_db_subnet_group.database-subnet.name
  vpc_security_group_ids = [aws_security_group.Database_security_group.id]
}

```

## Bastion Host
A bastion host is set up for SSH access to instances in the private subnets.

```
resource "aws_instance" "Public-WebTemplate" {
  ami             = data.aws_ami.ubuntu.id // Ubuntu  AMI
  instance_type   = var.instance_type
  subnet_id       = aws_ssm_parameter.pub-sn-1.value
  security_groups = [aws_security_group.alb_security_group.id]
  key_name        = "YourKeyName"

  tags = {
    Name = "${var.name}-public-bastion"
  }
}
```

## Conclusion
By following this guide, you can create a secure and scalable infrastructure on AWS using Terraform. This setup ensures that your resources are well-organized, secure, and capable of handling varying loads. Feel free to modify the configuration to suit your specific needs and requirements. Happy coding!

# Perform
### Terraform Init
Execute the command **terraform init** to setup the project workspace.
### Terraform plan
Excute the command **terrraform plan** to get a preview of the resources, terraform is going to implement incase you go ahead with it. This will give you detailed informations on resources to be provisioned
### Terraform apply
Execute the command **terraform apply** to provision the infrastructure.
### Terraform destroy
Execute the command **terraform destroy** to destroy the infrastructure.

# Note
The resources created in this example may incur cost. So please make sure to destroy the infrastructure if you don't need it.