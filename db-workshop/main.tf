provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

# Virtual Private Cloud (VPC)

resource "aws_vpc" "main" {
  cidr_block = local.vpc_cidr_block

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.name}-vpc"
  }
}

# Internet Gateway (IGW)

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.name}-igw"
  }
}

# Subnets (1 public & 2 private)

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = local.public_subnet_cidr_block

  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name}-public-subnet"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = local.private_subnet_1_cidr_block

  tags = {
    Name = "${local.name}-private-subnet-1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = local.private_subnet_2_cidr_block

  tags = {
    Name = "${local.name}-private-subnet-2"
  }
}

# Route tables & RT associations

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.name}-private-rt"
  }
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
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
    Name = "${local.name}-public-nacl"
  }
}

# EC2 (Bastion instance)

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.public_key
}

resource "aws_instance" "bastion" {
  ami           = local.linux_ami
  instance_type = "t2.micro"

  subnet_id = aws_subnet.public.id

  associate_public_ip_address = true

  key_name = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_security_group.bastion.id]

  tags = {
    Name = "${local.name}-instance"
  }
}

# Security groups

resource "aws_security_group" "bastion" {
  name   = "${local.name}-bastion-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH Access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name}-bastion-sg"
  }
}

resource "aws_security_group" "aurora" {
  name   = "${local.name}-aurora-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
    description     = "Amazon Aurora DB Access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name}-aurora-sg"
  }
}

# RDS Database subnet group

resource "aws_db_subnet_group" "main" {
  name = "${local.name}-main-db-subnet-group"

  # Attach the 2 private subnets for read & write replicas
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name = "${local.name}-main-db-subnet-group"
  }
}
