provider "aws" {
  profile = "default"
}


resource "aws_vpc" "vpc_main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    name = Vpc_Main
  }
}

resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnets_cidr)
  vpc_id            = aws_vpc.vpc_main.id
  cidr_block        = element(var.public_subnets_cidr, count.index)
  availability_zone = element(var.availability_zone, count.index)

  tags = {
    name = "Public Subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "subnet_private" {
  count             = length(var.private_subnets_cidr)
  vpc_id            = aws_vpc.vpc_main.id
  cidr_block        = element(var.private_subnets_cidr, count.index)
  availability_zone = element(var.availability_zone, count.index)

  tags = {
    name = "Private Subnet ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_main.id

  tags = {
    name = "vpc_main_igw"
  }

}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc_main.id

  route {
    cidr_block           = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    name = "Public Route "
  }

}

resource "aws_route_table_association" "public_rt_association" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_rt.id

}