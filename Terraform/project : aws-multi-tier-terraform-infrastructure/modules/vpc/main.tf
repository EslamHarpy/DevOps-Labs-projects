resource "aws_vpc" "production_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "production-vpc", Terraform = "true" }
}

resource "aws_subnet" "public_subnets" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.production_vpc.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true
  tags                    = { Name = "public-${each.key}", Terraform = "true" }
}

resource "aws_subnet" "private_subnets" {
  for_each          = var.private_subnets
  vpc_id            = aws_vpc.production_vpc.id
  cidr_block        = each.value
  availability_zone = each.key
  tags              = { Name = "private-${each.key}", Terraform = "true" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.production_vpc.id
  tags   = { Name = "main-igw" }
}

resource "aws_eip" "nat_eips" {
  for_each = var.public_subnets
  domain   = "vpc"
}

resource "aws_nat_gateway" "nat_gateways" {
  for_each      = var.public_subnets
  allocation_id = aws_eip.nat_eips[each.key].id
  subnet_id     = aws_subnet.public_subnets[each.key].id
  tags          = { Name = "nat-${each.key}" }
}

resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.production_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_route_table" "private_rtbs" {
  for_each = var.private_subnets
  vpc_id   = aws_vpc.production_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateways[each.key].id
  }
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rtbs[each.key].id
}

