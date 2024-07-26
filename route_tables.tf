# The public route table for the public subnet
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

# The public route table association with the public subnet
resource "aws_route_table_association" "Public-Subnet-1" {
  subnet_id      = aws_ssm_parameter.pub-sn-1.value
  route_table_id = aws_route_table.public-route.id
}

# This is a public route table to associate the public subnet 2 to the route table for internet access
resource "aws_route_table_association" "Public-Subnet-2" {
  subnet_id      = aws_ssm_parameter.pub-sn-2.value
  route_table_id = aws_route_table.public-route.id
}

# Private route table associated with the nat gateway.
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

# Route the private subnet to the nat gateway 

resource "aws_route_table_association" "nat_route_1" {
  subnet_id      = aws_ssm_parameter.pri-sn-1.value
  route_table_id = aws_route_table.private-route.id
}

resource "aws_route_table_association" "nat_route_2" {
  subnet_id      = aws_ssm_parameter.pri-sn-2.value
  route_table_id = aws_route_table.private-route.id
}

# Route the private database to the Nat Gateway

resource "aws_route_table_association" "nat_route_db_1" {
  subnet_id      = aws_subnet.private-db-subnet-1.id
  route_table_id = aws_route_table.private-route.id
}

resource "aws_route_table_association" "nat_route_db_2" {
  subnet_id      = aws_subnet.private-db-subnet-2.id
  route_table_id = aws_route_table.private-route.id
}