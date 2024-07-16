resource "aws_lb" "web-alb" {
  name               = "www-to-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.www-to-alb.id]
  subnets            = aws_subnet.public-subnet[*].id

  enable_deletion_protection = false

  tags = {
    Environment = "Access from www to ALB"
  }
  depends_on = [aws_security_group.www-to-alb] 
}

resource "aws_lb_target_group" "web-tg-images" {
  name        = "wb-target-group-images"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.devops-vpc.id
    health_check {
    port     = 80
    protocol = "HTTP"
    path = "/images/"
  }
}

resource "aws_lb_target_group" "web-tg-documents" {
  name        = "wb-target-group-register"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.devops-vpc.id
    health_check {
    port     = 80
    protocol = "HTTP"
    path = "/documents/"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.web-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "images_rule" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-tg-images.arn
  }

  condition {
    path_pattern {
      values = ["/images/*"]
    }
  }
}

resource "aws_lb_listener_rule" "documents_rule" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-tg-documents.arn
  }

  condition {
    path_pattern {
      values = ["/documents/*"]
    }
  }
}
