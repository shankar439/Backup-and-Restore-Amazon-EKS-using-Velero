
# Security Group for EC2 EIC Instance 
resource "aws_security_group" "PG-EKS-SG-EIC" {
  name = var.PG-EKS-SG-EIC
  vpc_id = aws_vpc.PG-EKS-VPC.id
  
  ingress {
    description      = "SSH from all CIDR"
    from_port        = var.ssh-portnumber
    to_port          = var.ssh-portnumber
    protocol         = var.tcp-name
    cidr_blocks      = [var.all-cidr]
    ipv6_cidr_blocks = [var.all-cidr-ipv6]
  }
  
  ingress {
    description      = "HTTP from all CIDR"
    from_port        = var.http-portnumber
    to_port          = var.http-portnumber
    protocol         = var.tcp-name
    cidr_blocks      = [var.all-cidr]
    ipv6_cidr_blocks = [var.all-cidr-ipv6]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.all-cidr]
    ipv6_cidr_blocks = [var.all-cidr-ipv6]
  }

  tags = {
    Name = var.PG-EKS-SG-EIC
  }
}


######################################################
# This SG rule is added to to access the Security Group of EFS from EKS-Node-SG
######################################################

resource "aws_security_group_rule" "EFS-SG-Rule" {
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  security_group_id = var.EFS-SG-ID
  source_security_group_id = module.eks.node_security_group_id
}