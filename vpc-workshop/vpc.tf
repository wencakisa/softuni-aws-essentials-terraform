# Virtual Private Cloud (VPC)

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name}-vpc"
  }
}

# Internet Gateway (IGW)

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-igw"
  }
}

# Subnets

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr_block

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-public-subnet"
  }
}

# Route Tables (RT)

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Network Access Control Lists (NACLs)

resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.main.id

  subnet_ids = [aws_subnet.public.id]

  ingress {
    rule_no    = 200
    action     = "allow"
    protocol   = "tcp"
    from_port  = 0
    to_port    = 65535
    cidr_block = "0.0.0.0/0"
  }

  egress {
    rule_no    = 200
    action     = "allow"
    protocol   = "tcp"
    from_port  = 0
    to_port    = 65535
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "${var.name}-public-nacl"
  }
}
