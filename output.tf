output "EKS-endpoint" {
  value = module.eks.cluster_endpoint
}
output "EKS-name" {
  value = module.eks.cluster_name
}

output "ElasticIP" {
  value = aws_eip.PG-EKS-eip-NAT.public_ip
}

