# Virtual Private Cloud (VPC)

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name}-vpc"
  }
}

# Availability zones (AZs)

data "aws_availability_zones" "available" {}

# Internet Gateway (IGW)

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-igw"
  }
}

# Subnets

resource "aws_subnet" "public" {
  count             = var.az_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 2, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-public-subnet-${count.index}"
  }
}

# Route Tables (RT)

resource "aws_route_table" "public" {
  count  = var.az_count
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.name}-public-rt-${count.index}"
  }
}

resource "aws_route_table_association" "public" {
  count = var.az_count

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public.*.id, count.index)
}

# Network Access Control Lists (NACLs)

resource "aws_network_acl" "public" {
  count = var.az_count

  vpc_id = aws_vpc.main.id

  subnet_ids = [element(aws_subnet.public.*.id, count.index)]

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
    Name = "${var.name}-public-nacl-${count.index}"
  }
}
