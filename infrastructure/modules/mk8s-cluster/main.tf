terraform {
  required_providers {
    nebius = {
      source = "terraform-provider.storage.eu-north1.nebius.cloud/nebius/nebius"
    }
  }
}

###################################
# MK8s Cluster Resource
###################################
resource "nebius_mk8s_v1_cluster" "main" {
  parent_id = var.project_id
  name = var.cluster_name
  labels = var.labels

  control_plane = {
    subnet_id         = var.subnet_id
    etcd_cluster_size = var.etcd_cluster_size
    version           = var.cluster_version
    endpoints = var.enable_public_endpoint ? {
      public_endpoint = {}
    } : null
    audit_logs = var.enable_audit_logs ? {} : null
  }
  kube_network = var.service_cidrs != null ? {
    service_cidrs = var.service_cidrs
  } : null
}
