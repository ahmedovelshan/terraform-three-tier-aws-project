resource "aws_launch_template" "my-ap-images" {
  image_id = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.alb-to-web.id]
  user_data = filebase64("images_data.sh")
}

resource "aws_launch_template" "my-ap-documents" {
  image_id = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.alb-to-web.id]
  user_data = filebase64("documents_data.sh")
}



resource "aws_autoscaling_group" "app-documents" {
  desired_capacity   = 2
  max_size           = 2
  min_size           = 2
  vpc_zone_identifier = aws_subnet.web-subnet[*].id
  target_group_arns = [aws_lb_target_group.web-tg-documents.id]
  launch_template {
    id      = aws_launch_template.my-ap-documents.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_group" "app-images" {
  desired_capacity   = 2
  max_size           = 2
  min_size           = 2
  vpc_zone_identifier = aws_subnet.web-subnet[*].id
  target_group_arns = [aws_lb_target_group.web-tg-images.id]
  launch_template {
    id      = aws_launch_template.my-ap-images.id
    version = "$Latest"
  }
}
