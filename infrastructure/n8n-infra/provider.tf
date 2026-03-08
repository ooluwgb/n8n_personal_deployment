terraform {
  required_version = ">=1.8.0"
  required_providers {
    nebius = {
      source  = "terraform-provider.storage.eu-north1.nebius.cloud/nebius/nebius"
      version = ">= 0.5.55"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.10.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.23.0"
    }
  }
}

provider "nebius" {
  service_account = {
    private_key_file = var.nb_private_key_file
    public_key_id    = var.nb_public_key_id
    account_id       = var.nb_service_account_id
  }
}


###################################
# Kubernetes & Helm Providers
###################################
provider "kubernetes" {
  config_path = var.kubeconfig_path
}


provider "helm" {
  kubernetes = {
    config_path = var.kubeconfig_path
  }
}