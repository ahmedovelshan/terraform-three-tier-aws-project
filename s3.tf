resource "aws_s3_bucket" "images-documents" {
  bucket = "images-documents"

  tags = {
    Name        = "My images and documents"
  }
}


resource "aws_s3_object" "documents_folder" {
  bucket = aws_s3_bucket.images-documents.bucket
  for_each = var.folders
  key    = each.value
}

resource "aws_s3_access_point" "private_access_point" {
  bucket                    = aws_s3_bucket.images-documents.bucket
  name                      = "accesspoint-for-local"
  
  vpc_configuration {
    vpc_id                  = aws_vpc.devops-vpc.id
  }
}

resource "aws_s3_bucket_public_access_block" "images-documents-block" {
  bucket = aws_s3_bucket.images-documents.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_vpc_endpoint" "for_s3_endpoint" {
  vpc_id            = aws_vpc.devops-vpc.id
  service_name      = "com.amazonaws.eu-central-1.s3"
  vpc_endpoint_type = "Interface"
  subnet_configuration {
    ipv4      = "10.0.3.200"
    subnet_id = aws_subnet.db-subnet[0].id
  }
  subnet_configuration {
    ipv4      = "10.0.4.200"
    subnet_id = aws_subnet.db-subnet[1].id
  }
  subnet_ids = [
    for subnet in aws_subnet.db-subnet : subnet.id
  ]
}

output "bucket_arn" {
  value = aws_s3_bucket.images-documents.arn
}

