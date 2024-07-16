variable "vpc" {
  description = "VPC Name"
  type = string
  default = "10.0.0.0/16"
}
variable "vpc-tag" {
  description = "VPC Tag name"
  type = string
  default = "Devops-VPC"
  
}
variable "availability_zone" {
  type    = list(string)
  default = ["eu-central-1a", "eu-central-1b"]
}

#Variables for Web subnet 
variable "web-subnet-cidr" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "web-subnet-tag" {
  type    = string
  default = "subnet for web resources"
}
#Variables for DB subnet 
variable "db-subnet-cidr" {
  type    = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "db-subnet-tag" {
  type    = string
  default = "subnet for db resources"
}


#Variables for Public subnet 
variable "public-subnet-cidr" {
  type    = list(string)
  default = ["10.0.5.0/24", "10.0.6.0/24"]
}

variable "public-subnet-tag" {
  type    = string
  default = "subnet for public resources"
}

#Port list

variable "port-1" {
  description = "List of ports to allow"
  type = list(string)
  default = ["80", "443"]
}

variable "port-2" {
  description = "List of ports to allow"
  type = list(string)
  default = ["3306"]
}

variable "ami" {
  description = "VM OS aim"
  type = string
  default = "ami-0e872aee57663ae2d"
}

variable "instance_type" {
  description = "instance type"
  type = string
  default = "t2.micro"
}

variable "folders" {
  type = map(string)
  default = {
    documents = "var/www/html/documents/"
    images    = "var/www/html/images/"
  }
}
