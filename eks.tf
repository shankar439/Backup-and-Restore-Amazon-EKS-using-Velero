module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

# Lets give our EKS cluster a Name and the Kubernetes vertion to be used
  cluster_name    = var.deployment-name
  cluster_version = "1.28"

# This portion indicate that our cluster entpoint is accessible both from outside and inside the VPC 
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

# Here we are mentioning the VPC to use. 
# The subnets where mentioned to place the worker nodes in it.
  vpc_id     = aws_vpc.PG-EKS-VPC.id
  subnet_ids = [aws_subnet.PG-EKS-private-ap-south-1a.id , aws_subnet.PG-EKS-private-ap-south-1b.id, aws_subnet.PG-EKS-private-ap-south-1c.id]

# Enable_irsa IAM role for Service Account this is the part where we connect from EKS pod to other AWS services 
# by leverage the use of IAM to attach role to kubernetes Service Account. 
# This will create an OpenID Connect Provider for EKS.
  enable_irsa = true


  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }


######################################################
# This SG rule is added to Worker Node Security Group beacause to access the Worker Node from EIC Endpoint.
######################################################

  node_security_group_additional_rules = {
    ingress_eic_ssh = {
      description = "added this rule to access all worker node in private subnet from EIC endpoint"
      protocol    = "tcp"
      from_port   = 22
      to_port     = 22
      type        = "ingress"
      source_cluster_security_group = false
      source_security_group_id = aws_security_group.PG-EKS-SG-EIC.id
    }
  }




# The EKS managed node groups will take care of the worker node patch, update and autoscaling using autoscaler
  eks_managed_node_groups = {
    spot = {

      name = "spot-eks-mng"
      use_name_prefix = true
      ami_id = "ami-07f0f3deaa0c4dffa"
      enable_bootstrap_user_data = true
      pre_bootstrap_user_data = <<-EOT
        mkdir -p /mnt/efs
        mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-0b3757111174.efs.ap-south-1.amazonaws.com:/ /mnt/efs
      EOT  

      desired_size = 1
      min_size     = 1
      max_size     = 5

      labels = {
        role = "spot"
      }

      instance_types = ["t3.small"]
      capacity_type  = "SPOT"

    }
  }

  tags = {
    Name = "${var.deployment-name}"
  }
}
