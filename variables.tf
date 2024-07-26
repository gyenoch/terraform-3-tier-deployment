variable "name" {
  default = "success"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public-subnet-01-cidr" {
  default = "10.0.1.0/24"
}

variable "public-subent-02-cidr" {
  default = "10.0.2.0/24"
}

variable "private-subent-01-cidr" {
  default = "10.0.3.0/24"
}

variable "private-subent-02-cidr" {
  default = "10.0.4.0/24"
}

variable "private-db-subnet-1-cidr" {
  default = "10.0.5.0/24"
}

variable "private-db-subnet-2-cidr" {
  default = "10.0.6.0/24"
}

variable "database-instance-class" {
  default = "db.t3.micro"
}

variable "multi-az-deployment" {
  default = true
}

variable "lb" {
  default = "App Load balancer"
}

variable "instance_type" {
  default = "t3.micro"
}


variable "db-username" {
  default = "admin"
}

variable "rds-username-file" {
  default = "rds-db-password.txt"
}

variable "rds-password-file" {
  default = "db-username.txt"
}

variable "rds-credential-file" {
  default = "rds-credential.txt"
}

variable "availability-1" {
  default = "us-east-1a"
}

variable "availability-2" {
  default = "us-east-1b"
}

variable "key-pair" {
  default = "linux_machine"
}