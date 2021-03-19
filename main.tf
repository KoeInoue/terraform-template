# Variables import form terraform.tfvars
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "key_name" {}
variable "public_key_path" {}

# Provider
provider "aws" {                  // use AWS
  access_key = var.aws_access_key // this information is credential so use the variables on ./terraform.tfvars
  secret_key = var.aws_secret_key // this information is credential so use the variables on ./terraform.tfvars
  region     = "ap-northeast-1"   // region
}

# VPC
resource "aws_vpc" "myVPC" { // aws vpc which named "myVPC"
  cidr_block           = "10.1.0.0/16"
  instance_tenancy     = "default" // "defalut" - The instance runs on the shared hardware.
  enable_dns_support   = "true"
  enable_dns_hostnames = "false"
  tags = {
    Name = "myVPC" // name of VPC
  }
}

# Internet Gateway
resource "aws_internet_gateway" "myGW" { // aws internet gateway which named "myGW"
  vpc_id = aws_vpc.myVPC.id              // refer the id of vpc resource ${resource.resourceName.id}
}

# Public Subnet
resource "aws_subnet" "public-a" {
  vpc_id            = aws_vpc.myVPC.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "ap-northeast-1a"
}

# Route Table
resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.myVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myGW.id
  }
}

# association between a route table and a subnet
resource "aws_route_table_association" "puclic-a" {
  subnet_id      = aws_subnet.public-a.id
  route_table_id = aws_route_table.public-route.id
}

# Security Group
resource "aws_security_group" "admin" {
  name        = "admin"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.myVPC.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

# EC2 Instance
resource "aws_instance" "cm-test" {
  ami           = "ami-0f27d081df46f326c"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.auth.id
  vpc_security_group_ids = [
    aws_security_group.admin.id
  ]
  subnet_id                   = aws_subnet.public-a.id
  associate_public_ip_address = "true"
  root_block_device {
    volume_type = "gp2"
    volume_size = "20"
  }
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_type = "gp2"
    volume_size = "100"
  }
  tags = {
    Name = "cm-test"
  }
}

# Out Put Result
output "public_ip_of_cm-test" {
  value = aws_instance.cm-test.public_ip
}
