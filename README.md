<h1 align="center"> AWS </h1>
<h2 align="center"> Backup-and-Restore-Amazon-EKS-using-Velero </h2>

### This Repo contains the instruction, Resources and Details to Backup and restore the Amazon EKS Cluster using Velero in proper and secure way. The Terraform code will deploy Velero app in the EKS using HELM. We will use Amazon Simple Storage Service (S3) as the storage backend for Velero backups.


![imagegit](https://github.com/shankar439/Images/assets/70714976/d1370c1f-f5b5-458f-b285-fca10989a2c3)


<br>


# Table of Contents
- <a href="#prerequisites"> Prerequisites </a>
- <a href="#what-is-velero-and-its-advantages"> Velero </a>
- <a href="#terraform"> Terraform code </a>
- <a href="#explanation"> Explanation </a>
- <a href="#resources"> Resources </a>
- <a href="#conclusion"> Conclusion </a>


<br>
<br>


# Prerequisites

Before you begin, ensure that you have the following prerequisites set up for this Demo:
1. AWS Account: You need an AWS account with appropriate permissions for EKS, IAM, and other required services.
2. Terraform: Install Terraform by following the official [Terraform Installation Guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).
3. AWS CLI: Configure the AWS CLI with your AWS credentials. You can follow the instructions in the [AWS CLI User Guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-authentication-user.html).
4. kubectl: Install kubectl for interacting with the Kubernetes cluster. You can install it by following the [Kubectl Installation Guide](https://kubernetes.io/docs/tasks/tools/).
5. AWS S3 Bucket in the same AWS Region or in different AWS Region.
6. Pre Created [IAM Policy](https://aws.amazon.com/blogs/containers/backup-and-restore-your-amazon-eks-cluster-resources-using-velero/) for Velero IAM Role
7. [Velero cli](https://velero.io/docs/v1.8/basic-install/).

<br>
<br>
<br>


# What is Velero and it's advantages ?. 

  - [Velero](https://velero.io/docs/v1.12/) `Velero is an open-source backup and disaster recovery tool designed specifically for Kubernetes. Here are some key benefits of using EKS:`
  - ### Advantages:
    - `Kubernetes Backup` - Velero provides a solution for backup and recovery of Kubernetes resources. It backs up not just application data but also associated configurations, secrets, and custom resources..

    - `Multi-Cloud Compatibility` - Migrate cluster resources into other clusters into a different Cloud Provider.

    - `Flexible Storage Options` - Velero supports various storage backends, including cloud storage providers (AWS S3, Google Cloud Storage, Azure Blob Storage)
    

<br>
<br>
<br>


<h1 align="center">Lets Begin </h1>

<img align="right" src="https://github.com/shankar439/Images/assets/70714976/2396aba8-823a-4846-b11b-a487c5f2b48e" height="140" alt="Kubernetes"> 
<img align="right" src="https://github.com/shankar439/Images/assets/70714976/e5fa9512-1398-4f26-9b0d-87133f415133" height="140" alt="Kubernetes"> 


- Commands Used for this Demo.

    - aws configure
    - terraform init
    - terraform plan
    - terraform apply
    - terraform destroy
    - aws eks update-kubeconfig --region ap-south-1 --name PG-EKS
    - aws eks update-kubeconfig --region ap-south-1 --name PG-EKS --dry-run
    - velero backup create pg-eks
    - velero restore create pg-eks-restore --from-backup pg-eks
    - velero backup get
    - velero restore get


<br>
<br>
<br>


# Terraform

- In this AWS-EKS Terraform code the Helm provider is used to Deploy Velero while the creation of EKS.
- The IAM role with policy to access EC2 and S3 is attached to the Velero using Service Account.


<br>


# Explanation

- In this demo we will create an EKS cluster from scratch using terraform and we will install Velero in the same cluster.

- And create some workload in the cluster and get a backup.

- Then use the same Terraform code to create a secondary cluster in different region just for demo and restore the resource in secondary cluster.

- Enable_irsa `(IAM role for Service Account)` this is the part where we connect Velero pod to access S3 Bucket. 
Enable_irsa will create an OpenID Connect Provider for EKS.
```yaml
enable_irsa = true
```

- Lets create the Terraform resource which is helm release and provide the needed details like name, helm repo URL, chart version and namespace.
```yaml
resource "helm_release" "velero" {
  name       = "velero"
  repository = "https://vmware-tanzu.github.io/helm-charts"
  chart      = "velero"
  create_namespace = true
  version    = "5.1.0"
}
```

- We also need to provide the AWS details to configure the Velero to backup and restore, those details are aws-region, S3 bucket name and the plugin to access AWS resources.
```yaml
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
```

- Finally attach the created IAM Role to the default service account in the velero namespace.
```yaml
  set {
    name  = "serviceAccount.server.name"
    value = "velero"
  }
  set {
    name  = "serviceAccount.server.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "arn:aws:iam::361351111148:role/velero-eks-iam-role"
    type      = "string"
  }
```


- After terraform init, apply the cluster will be ready in 10 min.

- Once every thing is created and cluster is accessible lets create the backup. please make sure to have some of kubernetes workload running in EKS for demo.
```yaml
velero backup create pg-eks
```

- To make sure the backup is successful and to list it use below command.
```yaml
velero backup get
``` 
- It is possible to fine grain backup like only backup the specific namespaces and cluster resources. For more please see the [Velero Cmd](https://velero.io/docs/v1.9/backup-reference/)

- create the second cluster to restore or you can delete all the workload and we can restore in the same cluster. This will restore the Kubernetes resources from the backup we created.
```yaml
velero restore create pg-eks-restore --from-backup pg-eks
```

- I too installed Nginx-ingress controller using the Helm provider using Terraform code.
```yaml
resource "helm_release" "nginx" {
  name       = "nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  create_namespace = true
  version    = "4.8.1"
}
```

<br>
<br>
<br>


# Resources

- [AWS-EKS BackUp Official](https://aws.amazon.com/blogs/containers/backup-and-restore-your-amazon-eks-cluster-resources-using-velero/)
- [AWS-EKS Examples](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/eks_managed_node_group/main.tf)
- [Velero Commands](https://velero.io/docs/v1.9/backup-reference/)
- [Terraform Helm Release](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)


<br>
<br>
<br>


# Conclusion

- By this setup, we've covered setting up Velero for backup and restore operations in an Amazon EKS environment using S3 storage. The combination of Velero, EKS, and AWS S3 provides a reliable solution for safeguarding our Kubernetes workloads and data. This setup ensures data resilience and disaster recovery for our EKS cluster.


<br>
<br>

<h1 align="center" id="END"> END </h1>
