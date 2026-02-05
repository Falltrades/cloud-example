resource "aws_vpc" "eks" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.eks.id
  cidr_block              = cidrsubnet(aws_vpc.eks.cidr_block, 8, count.index + 10)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                     = "eks-public-${count.index}"
    "kubernetes.io/role/elb" = "1" # This tag tells the controller this is a public subnet
  }
}

resource "aws_subnet" "eks" {
  count                   = 2
  vpc_id                  = aws_vpc.eks.id
  cidr_block              = cidrsubnet(aws_vpc.eks.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    "kubernetes.io/cluster/nginx-cluster" = "shared"
    "kubernetes.io/role/elb"              = "1"
  }
}

resource "aws_internet_gateway" "eks" {
  vpc_id = aws_vpc.eks.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "eks" {
  depends_on = [aws_internet_gateway.eks]

  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id 

  tags = {
    Name = "eks-nat-gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks.id
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "eks" {
  vpc_id = aws_vpc.eks.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks.id
  }
}

resource "aws_route_table_association" "eks" {
  count          = length(aws_subnet.eks)
  subnet_id      = aws_subnet.eks[count.index].id
  route_table_id = aws_route_table.eks.id
}
