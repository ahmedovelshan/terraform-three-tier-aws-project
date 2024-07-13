resource "aws_security_group" "www-to-alb" {
    vpc_id              = aws_vpc.devops-vpc.id
    name                = "www-to-alb"
    description         = "Access from WWW to ALB"
    dynamic "ingress" {
        for_each = var.port-1
        content {
          protocol = "tcp"
          from_port = ingress.value
          to_port = ingress.value
          cidr_blocks = [ "0.0.0.0/0" ]
        }      
    }
    egress {
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = [ "0.0.0.0/0" ]
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
        cidr_blocks = [aws_security_group.ec2-endpoint-connection.id]
    }
    egress {
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    depends_on = [
    aws_security_group.ec2-endpoint-connection
  ]
}

resource "aws_security_group" "web-to-db" {
    vpc_id              = aws_vpc.devops-vpc.id
    name                = "web-to-db"
    description         = "Access from WEB to DB subnet"
    dynamic "ingress" {
        for_each = var.port-2
        content {
          protocol = "tcp"
          from_port = ingress.value
          to_port = ingress.value
          cidr_blocks = var.web-subnet-cidr
        }     
    }
    egress {
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = [ "0.0.0.0/0" ]
    }
}
