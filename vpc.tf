######################################################
# This part is blocked because of vpc and eks infra has been seperated due to the creation of EFS.
# And only EIC endpoint, NAT Gateway and related will be created from this code.
######################################################

resource "aws_vpc" "PG-EKS-VPC" {
  cidr_block = var.VPC-cidr

  tags = {
    Name = "${var.deployment-name}-VPC"
  }
}


# EC2 Instance Connect Endpoint - EIC
resource "aws_ec2_instance_connect_endpoint" "PG-EKS-EIC-Endpoint" {
  subnet_id = aws_subnet.PG-EKS-private-ap-south-1a.id
  security_group_ids = [ aws_security_group.PG-EKS-SG-EIC.id ]

  tags = {
    Name = "${var.deployment-name}-EIC-Endpoint"
  }
}


# # Public subnets in region ap-south-1 in all three AZ

resource "aws_subnet" "PG-EKS-public-ap-south-1a" {
  cidr_block = var.public-south-1a-cidr
  availability_zone = var.ap-south-1a
  vpc_id = aws_vpc.PG-EKS-VPC.id
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.deployment-name}-public-ap-south-1a"
  }
}

resource "aws_subnet" "PG-EKS-public-ap-south-1b" {
  cidr_block = var.public-south-1b-cidr
  availability_zone = var.ap-south-1b
  vpc_id = aws_vpc.PG-EKS-VPC.id
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.deployment-name}-public-ap-south-1b"
  }
}

resource "aws_subnet" "PG-EKS-public-ap-south-1c" {
  cidr_block = var.public-south-1c-cidr
  availability_zone = var.ap-south-1c
  vpc_id = aws_vpc.PG-EKS-VPC.id
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.deployment-name}-public-ap-south-1c"
  }
}



# # Private subnets in region ap-south-1 in all three AZ

resource "aws_subnet" "PG-EKS-private-ap-south-1a" {
  cidr_block = var.private-south-1a-cidr
  availability_zone = var.ap-south-1a
  vpc_id = aws_vpc.PG-EKS-VPC.id

  tags = {
    Name = "${var.deployment-name}-private-ap-south-1a"
  }
}

resource "aws_subnet" "PG-EKS-private-ap-south-1b" {
  cidr_block = var.private-south-1b-cidr
  availability_zone = var.ap-south-1b
  vpc_id = aws_vpc.PG-EKS-VPC.id

  tags = {
    Name = "${var.deployment-name}-private-ap-south-1b"
  }
}

resource "aws_subnet" "PG-EKS-private-ap-south-1c" {
  cidr_block = var.private-south-1c-cidr
  availability_zone = var.ap-south-1c
  vpc_id = aws_vpc.PG-EKS-VPC.id

  tags = {
    Name = "${var.deployment-name}-private-ap-south-1c"
  }
}