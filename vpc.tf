resource "aws_vpc" "devops-vpc" {
  cidr_block       = var.vpc
  instance_tenancy = "default"
  tags = {
    Name = var.vpc-tag
  }
}

#Create two subnet for web resources
resource "aws_subnet" "web-subnet" {
  vpc_id                  = aws_vpc.devops-vpc.id
  cidr_block              = element(var.web-subnet-cidr, count.index)
  availability_zone       = element(var.availability_zone, count.index)
  map_public_ip_on_launch = false
  count                   = length(var.web-subnet-cidr)

  tags = {
    Name = "${var.web-subnet-tag}-${count.index}"
  }
}

#Create two subnet for db resources
resource "aws_subnet" "db-subnet" {
  vpc_id                  = aws_vpc.devops-vpc.id
  cidr_block              = element(var.db-subnet-cidr, count.index)
  availability_zone       = element(var.availability_zone, count.index)
  map_public_ip_on_launch = false
  count                   = length(var.db-subnet-cidr)

  tags = {
    Name = "${var.db-subnet-tag}-${count.index}"
  }
}

#Create two subnet for public resources
resource "aws_subnet" "public-subnet" {
  vpc_id                  = aws_vpc.devops-vpc.id
  cidr_block              = element(var.public-subnet-cidr, count.index)
  availability_zone       = element(var.availability_zone, count.index)
  map_public_ip_on_launch = false
  count                   = length(var.public-subnet-cidr)

  tags = {
    Name = "${var.public-subnet-tag}-${count.index}"
  }
}


#Access outside resources
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.devops-vpc.id

  tags = {
    Name = "GW for VPC"
  }
}


#Routing for web and db servers to access internet via IGW
resource "aws_eip" "eip" {
    domain = "vpc"
    count = 2
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = aws_subnet.public-subnet[count.index].id
  count = 2
  tags = {
    Name = "NAT GW"
  }
  depends_on = [aws_internet_gateway.igw]
}


resource "aws_route_table" "route-ngw" {
  count = 2
  vpc_id = aws_vpc.devops-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw[count.index].id
  }
  tags = {
    Name = "Used to access to internet via NATGW"
  }
}

resource "aws_route_table_association" "rt-web" {
  count =2
  subnet_id      = aws_subnet.web-subnet[count.index].id
  route_table_id = aws_route_table.route-ngw[count.index].id
}


resource "aws_route_table_association" "rt-db" {
  count =2
  subnet_id      = aws_subnet.db-subnet[count.index].id
  route_table_id = aws_route_table.route-ngw[count.index].id
}


# Route tables for public subnets to IGW
resource "aws_route_table" "route-public" {
  vpc_id = aws_vpc.devops-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Route table for public subnet"
  }
}


resource "aws_route_table_association" "rt-public" {
  count = 2
  subnet_id      = aws_subnet.public-subnet[count.index].id
  route_table_id = aws_route_table.route-public.id
}
