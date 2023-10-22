# ############################################
# IAM role creation block. 
# The below block will creat and IAM role to access S3 and EC2 instance 
# this role is used by velero pod running in EKS and this role will be acctached to Service Account of velero 
# using the Amazon EKS feture IRSA - (IAM Role For Service Account)
# ############################################

module "iam_eks_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "velero-eks-iam-role"

  role_policy_arns = {
    policy = "arn:aws:iam::361351211117:policy/velero-eks-policy"
  }

  oidc_providers = {
    one = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["velero:velero"]
    }
  }
}
