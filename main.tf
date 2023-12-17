terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

# Create VPCs
resource "aws_vpc" "sap-nprod-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

# Create private subnets in sap-nprod-vpc
resource "aws_subnet" "private_subnet1a" {
  vpc_id                  = aws_vpc.sap-nprod-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "private_subnet1b" {
  vpc_id                  = aws_vpc.sap-nprod-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
}

# Create security group for VPC1 private subnets
resource "aws_security_group" "sg_sap-nprod-vpc_private" {
  name        = "sg_sap-nprod-vpc_private"
  description = "Security Group for VPC1 Private Subnets"
  vpc_id      = aws_vpc.sap-nprod-vpc.id
}

# Allow inbound traffic on specific ports (adjust as needed)
resource "aws_security_group_rule" "sg_sap-nprod-vpc_private_inbound" {
  security_group_id = aws_security_group.sg_sap-nprod-vpc_private.id
  type              = "ingress"
  from_port         = 22  # SSH
  to_port           = 80  # HTTP
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Create route table for VPC1 private subnets
resource "aws_route_table" "rt_sap-nprod-vpc_private" {
  vpc_id = aws_vpc.sap-nprod-vpc.id
}

# Associate route table with VPC1 private subnets
resource "aws_route_table_association" "rta_sap-nprod-vpc_private_subnet1a" {
  subnet_id      = aws_subnet.private_subnet1a.id
  route_table_id = aws_route_table.rt_sap-nprod-vpc_private.id
}

resource "aws_route_table_association" "rta_sap-nprod-vpc_private_subnet1b" {
  subnet_id      = aws_subnet.private_subnet1b.id
  route_table_id = aws_route_table.rt_sap-nprod-vpc_private.id
}
