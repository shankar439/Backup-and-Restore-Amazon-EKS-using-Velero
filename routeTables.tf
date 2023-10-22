######################################################
# This part is blocked because of vpc and eks infra has been seperated due to the creation of EFS.
# Every thing is blocked expect NAT Gateway, EIP and related Routes.
######################################################

# PG-EKS-Internet-GW - Resource IGW for internet access for publica and private subnet resources
resource "aws_internet_gateway" "PG-EKS-IGW" {
  vpc_id = aws_vpc.PG-EKS-VPC.id

  tags = {
    Name = "${var.deployment-name}-IGW"
  }
}

# ElasticIP - Resource ElasticIP EIP for NAT Gateway
resource "aws_eip" "PG-EKS-eip-NAT" {
  domain = "vpc"
  tags = {
    Name = "${var.deployment-name}-NAT-eip"
  }
}

# PG-EKS-NAT-GW - Resource NAT Gateway for internet access for Private subnet resources
resource "aws_nat_gateway" "PG-EKS-NAT-GW" {
  subnet_id = aws_subnet.PG-EKS-private-ap-south-1a.id
  allocation_id = aws_eip.PG-EKS-eip-NAT.id

  tags = {
    Name = "${var.deployment-name}-NAT-GW"
  }
}



# # PG-EKS-Route Table - Resources Route table for all public and private subnets 
resource "aws_route_table" "PG-EKS-public-RT" {
  vpc_id = aws_vpc.PG-EKS-VPC.id

  tags = {
    Name = "${var.deployment-name}-public-RT"
  }
}

resource "aws_route_table" "PG-EKS-private-RT" {
  vpc_id = aws_vpc.PG-EKS-VPC.id

  tags = {
    Name = "${var.deployment-name}-private-RT"
  }
}



# # PG-EKS-Route Table Association - Resource route table association for all subnets

resource "aws_route_table_association" "PG-EKS-public-ap-south-1a-association" {
  route_table_id = aws_route_table.PG-EKS-public-RT.id
  subnet_id = aws_subnet.PG-EKS-public-ap-south-1a.id
}

resource "aws_route_table_association" "PG-EKS-public-ap-south-1b-association" {
  route_table_id = aws_route_table.PG-EKS-public-RT.id
  subnet_id = aws_subnet.PG-EKS-public-ap-south-1b.id
}

resource "aws_route_table_association" "PG-EKS-public-ap-south-1c-association" {
  route_table_id = aws_route_table.PG-EKS-public-RT.id
  subnet_id = aws_subnet.PG-EKS-public-ap-south-1c.id
}

resource "aws_route_table_association" "PG-EKS-private-ap-south-1a-association" {
  route_table_id = aws_route_table.PG-EKS-private-RT.id
  subnet_id = aws_subnet.PG-EKS-private-ap-south-1a.id
}

resource "aws_route_table_association" "PG-EKS-private-ap-south-1b-association" {
  route_table_id = aws_route_table.PG-EKS-private-RT.id
  subnet_id = aws_subnet.PG-EKS-private-ap-south-1b.id
}

resource "aws_route_table_association" "PG-EKS-private-ap-south-1c-association" {
  route_table_id = aws_route_table.PG-EKS-private-RT.id
  subnet_id = aws_subnet.PG-EKS-private-ap-south-1c.id
}



# # AWS-Routes - Resource 'Routes' for public and private subnets 
# # to access internet using Internet and NAT Gateway.

resource "aws_route" "PG-EKS-public-internet-GW-routes" {
  route_table_id = aws_route_table.PG-EKS-public-RT.id
  gateway_id = aws_internet_gateway.PG-EKS-IGW.id
  destination_cidr_block = var.all-cidr
}

resource "aws_route" "PG-EKS-private-NAT-GW-routes" {
  route_table_id = aws_route_table.PG-EKS-private-RT.id
  nat_gateway_id = aws_nat_gateway.PG-EKS-NAT-GW.id
  destination_cidr_block = var.all-cidr
}

