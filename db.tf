resource "aws_db_subnet_group" "db-subnet-group" {
  name       = "db-subnet-group"
  subnet_ids = [for subnet in aws_subnet.db-subnet : subnet.id]
  description = "Database subnet group"
}

resource "aws_db_instance" "webdb" {
  allocated_storage             = 10
  db_name                       = "webdb"
  engine                        = "mysql"
  engine_version                = "8.0"
  instance_class                = "db.t3.micro"
  username                      = "awsroot"
  password                      = "5adfdfpasdfsdf"
  parameter_group_name          = "default.mysql8.0"
  availability_zone = var.availability_zone[0]
  db_subnet_group_name = aws_db_subnet_group.db-subnet-group.name
  vpc_security_group_ids = [aws_security_group.web-to-db.id]
}
