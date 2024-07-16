resource "aws_subnet" "ec2-endpoint-subnet" {
  vpc_id                  = aws_vpc.devops-vpc.id
  cidr_block              = "10.0.10.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "Subnet for EC2 Instance Connect Endpoint"
  }
}

resource "aws_security_group" "ec2-endpoint-connection" {
    vpc_id              = aws_vpc.devops-vpc.id
    name                = "ec2-endpoint-connection"
    description         = "Access from EC2 Endpoint to Private Subnet"
    ingress {
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    egress {
        protocol = "TCP"
        from_port = 22
        to_port = 22
        cidr_blocks = [ "10.0.1.0/24", "10.0.2.0/24" ]
    }

}


resource "aws_security_group" "alb-to-web" {
    vpc_id              = aws_vpc.devops-vpc.id
    name                = "alb-to-web"
    description         = "Access from ALB to WEB subnet"
    dynamic "ingress" {
        for_each = var.port-1
        content {
          protocol = "tcp"
          from_port = ingress.value
          to_port = ingress.value
          cidr_blocks = var.public-subnet-cidr
        }     
    }
    ingress {
        protocol = "TCP"
        from_port = 22
        to_port = 22
        security_groups = [aws_security_group.ec2-endpoint-connection.id]
    }	
    egress {
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = [ "0.0.0.0/0" ]
    }
}

resource "aws_ec2_instance_connect_endpoint" "for-resource-connection" {
  subnet_id = aws_subnet.ec2-endpoint-subnet.id
  security_group_ids = [aws_security_group.ec2-endpoint-connection.id]
}

