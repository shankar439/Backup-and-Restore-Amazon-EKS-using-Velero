##########################################################
# Velero Deployed using Helm through Terraform
##########################################################

resource "helm_release" "velero" {
  name       = "velero"
  repository = "https://vmware-tanzu.github.io/helm-charts"
  chart      = "velero"
  create_namespace = true
  version    = "5.1.0"

  set {
    name  = "cluster.enabled"
    value = "true"
  }


# velero init container
  set {
    name  = "initContainers"
    value = <<EOT
- name: velero-plugin-for-aws
  image: velero/velero-plugin-for-aws:v1.8.0
  volumeMounts:
  - mountPath: /target
    name: plugins
EOT
  }


# S3 - Region - AWS
#  Set the backupStorageLocation provider and bucket Name values
  set {
    name  = "configuration.backupStorageLocation[0].provider"
    value = "aws"
  }
  set {
    name  = "configuration.backupStorageLocation[0].bucket"
    value = "eks-velero-backup-shankar"
  }

#  Set the volumeSnapshotLocation provider value to aws and configure the region value to ap-south-1
  set {
    name  = "configuration.volumeSnapshotLocation[0].provider"
    value = "aws"
  }
  set {
    name  = "configuration.volumeSnapshotLocation[0].config.region"
    value = "ap-south-1"
  }



#  Set the credentials usesecret to false.
  set {
    name  = "credentials.useSecret"
    value = "false"
  }



#  ServiceAccount - Set both the Service Account Name and annotation values
  set {
    name  = "serviceAccount.server.name"
    value = "velero"
  }
  set {
    name  = "serviceAccount.server.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "arn:aws:iam::361351111148:role/velero-eks-iam-role"
    type      = "string"
  }

}



################################################################
# Nginx-Ingress-Controller Deployed using Helm through Terraform
################################################################
resource "helm_release" "nginx" {
  name       = "nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  create_namespace = true
  version    = "4.8.1"

}