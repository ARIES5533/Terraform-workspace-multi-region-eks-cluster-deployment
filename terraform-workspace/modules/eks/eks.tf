module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.32.1"

  cluster_name    = "${terraform.workspace}-olumoko" 
  cluster_version = "1.25"
  enable_irsa     = true

  fargate_profiles = {
    staging = {
      fargate_profile_name = "staging"
      # subnet_ids = [
      #   aws_subnet.private_us_east_1a.id,
      #   aws_subnet.private_us_east_1b.id
      # ]
      subnet_ids = var.vpc_primary_private_subnets
      fargate_profile_namespaces = [
        { namespace = "staging" }
      ]
    }
  }

  vpc_id = var.vpc_primary_id

  private_subnet_ids = var.vpc_primary_private_subnets

  managed_node_groups = {
    role = {
      capacity_type   = "ON_DEMAND"
      node_group_name = "general"
      instance_types  = ["t3.large"]
      desired_size    = "2"
      max_size        = "5"
      min_size        = "2"
    }
  }
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
  }
}


#############


module "kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.32.1"

  eks_cluster_id = module.eks_blueprints.eks_cluster_id

  # EKS Add-ons
  enable_amazon_eks_aws_ebs_csi_driver = true

  # Self-managed Add-ons
  enable_aws_efs_csi_driver = true

  # Optional aws_efs_csi_driver_helm_config
  aws_efs_csi_driver_helm_config = {
    repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
    version    = "2.4.0"
    namespace  = "kube-system"
  }

  enable_aws_load_balancer_controller = true

  enable_metrics_server = true
  enable_cert_manager   = true

  enable_cluster_autoscaler = true
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
    }
  }
}