locals {
  tags = {
    Project = var.project
  }
}

# AZ を CloudFormation の !GetAZs + !Select 相当にする
data "aws_availability_zones" "available" {
  state = "available"
}

########################################
# VPC
########################################
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.tags, {
    Name = "${var.name_prefix}Vpc"
  })
}

########################################
# Subnets
########################################
# Public 1a (= AZ[0])
resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_1a_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = merge(local.tags, {
    Name = "${var.name_prefix}PublicSubnet1a"
    Tier = "public"
  })
}

# Public 1c (= AZ[1])
resource "aws_subnet" "public_1c" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_1c_cidr
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = merge(local.tags, {
    Name = "${var.name_prefix}PublicSubnet1c"
    Tier = "public"
  })
}

# Private 1a
resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_1a_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = merge(local.tags, {
    Name = "${var.name_prefix}PrivateSubnet1a"
    Tier = "private"
  })
}

# Private 1c
resource "aws_subnet" "private_1c" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_1c_cidr
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = merge(local.tags, {
    Name = "${var.name_prefix}PrivateSubnet1c"
    Tier = "private"
  })
}

########################################
# IGW + Attach
########################################
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.tags, {
    Name = "${var.name_prefix}InternetGateway"
  })
}

########################################
# NAT 
########################################
resource "aws_eip" "nat_1a" {
  domain = "vpc"

  tags = merge(local.tags, {
    Name = "${var.name_prefix}NatEip1a"
  })
}

resource "aws_nat_gateway" "nat_1a" {
  allocation_id = aws_eip.nat_1a.id
  subnet_id     = aws_subnet.public_1a.id

  tags = merge(local.tags, {
    Name = "${var.name_prefix}NatGateway1a"
  })

  depends_on = [aws_internet_gateway.this]
}

########################################
# Route Tables
########################################
# Public RT
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.tags, {
    Name = "${var.name_prefix}PublicRouteTable"
  })
}

resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# Private RT
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.tags, {
    Name = "${var.name_prefix}PrivateRouteTable"
  })
}

resource "aws_route" "private_default" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_1a.id
}

########################################
# Route Table Associations
########################################
resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_1a" {
  subnet_id      = aws_subnet.private_1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_1c" {
  subnet_id      = aws_subnet.private_1c.id
  route_table_id = aws_route_table.private.id
}
