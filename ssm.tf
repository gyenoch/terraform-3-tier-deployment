resource "aws_ssm_parameter" "vpc-id" {
  name       = "${var.name}-vpcID"
  value      = aws_vpc.vpc-01.id
  type       = "String"
  depends_on = [aws_vpc.vpc-01]
}

resource "aws_ssm_parameter" "pub-sn-1" {
  type       = "String"
  name       = "${var.name}-Public-Subnet-1"
  value      = aws_subnet.pub-sn-1.id
  depends_on = [aws_subnet.pub-sn-1]
}

resource "aws_ssm_parameter" "pub-sn-2" {
  type       = "String"
  name       = "${var.name}-Public-Subnet-2"
  value      = aws_subnet.pub-sn-2.id
  depends_on = [aws_subnet.pub-sn-2]
}

resource "aws_ssm_parameter" "pri-sn-1" {
  type       = "String"
  name       = "${var.name}-Private-Subnet-1"
  value      = aws_subnet.pri-sn-1.id
  depends_on = [aws_subnet.pri-sn-1]
}

resource "aws_ssm_parameter" "pri-sn-2" {
  type       = "String"
  name       = "${var.name}-Private-Subnet-2"
  value      = aws_subnet.pri-sn-2.id
  depends_on = [aws_subnet.pri-sn-2]
}

resource "aws_ssm_parameter" "Private-DB-1" {
  type       = "String"
  name       = "${var.name}-Private-DB-1"
  value      = aws_subnet.private-db-subnet-1.id
  depends_on = [aws_subnet.private-db-subnet-1]
}

resource "aws_ssm_parameter" "Private-DB-2" {
  type       = "String"
  name       = "${var.name}-Private-DB-2"
  value      = aws_subnet.private-db-subnet-2.id
  depends_on = [aws_subnet.private-db-subnet-2]
}