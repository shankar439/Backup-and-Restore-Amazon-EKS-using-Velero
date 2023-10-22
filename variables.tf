# Common tag name for this release so that i can identify the resource is managed by terraform specific release.
variable "deployment-name" {
  default = "PG-EKS"
}

# variable for AWS region
variable "region" {
  default = "ap-south-1"
}

# This value is used to refer the EFS security Group ID
variable "EFS-SG-ID" {
  default = "sg-0fc924917a7f1111e"
  description = "This is the EFS Security Group ID"
}

#  VPC-CIDR - variable for VPC cidr and related subnets cidr which these values are appilcable for ap-south-1

variable "all-cidr" {
  default = "0.0.0.0/0"
}

variable "all-cidr-ipv6" {
  default = "::/0"
}

variable "VPC-cidr" {
  default = "10.0.0.0/16"
}

variable "public-south-1a-cidr" {
  default = "10.0.0.0/24"
}

variable "public-south-1b-cidr" {
  default = "10.0.1.0/24"
}

variable "public-south-1c-cidr" {
  default = "10.0.2.0/24"
}

variable "private-south-1a-cidr" {
  default = "10.0.16.0/20"
}

variable "private-south-1b-cidr" {
  default = "10.0.32.0/20"
}

variable "private-south-1c-cidr" {
  default = "10.0.48.0/20"
}



# AvailabilityZone - this below variable is used for providing different AZ names in ap-south-1

variable "ap-south-1a" {
  default = "ap-south-1a"
}

variable "ap-south-1b" {
  default = "ap-south-1b"
}

variable "ap-south-1c" {
  default = "ap-south-1c"
}




# variable for EC2 instance type
variable "instance_type" {
  default = "t2.micro"
  description = "variable for instance type "
}

#variable for EC2 instance AMI - Amazon Machine Image - Ubuntu instance
variable "ec2-instance-ami" {
  default = "ami-0f5ee92e2d63afc18"
}

#variable for ec2 instance tag
variable "aws_instance-tag-name" {
  default = "ec2-by-terraform"
}



# Security Group - variables for EKS
variable "PG-EKS-SG-EIC" {
  default = "PG-EKS-SG-EIC"
}



# Protocol - variables for protocol
variable "http-portnumber" {
  default = "80"  
}

variable "ssh-portnumber" {
  default = "22"  
}

variable "http-name" {
  default = "http"  
}

variable "tcp-name" {
  default = "tcp"  
}



# Spot Instance Details 
variable "spot-max-price" {
  default = "0.0038"
}