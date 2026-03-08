terraform {
  required_providers {
    nebius = {
      source = "terraform-provider.storage.eu-north1.nebius.cloud/nebius/nebius"
    }
  }
}

###################################
# Bastion Host — Root Module
###################################
# Single entry point that provisions a complete bastion:
#   1. Service account (service-account sub-module)
#   2. IP allocations  (allocation sub-module)
#   3. Boot disk       (compute-disk sub-module)
#   4. VM instance     (compute-instance sub-module)
###################################

###################################
# Service Account
###################################

module "service_account" {
  source = "./service-account"

  project_id                  = var.project_id
  tenant_id                   = var.tenant_id
  service_account_name        = var.service_account_name
  service_account_description = var.service_account_description
  auth_key_expires_at         = var.auth_key_expires_at
  iam_group_name              = var.iam_group_name
  labels                      = var.labels
}

###################################
# Static IP Allocations
###################################

module "allocation" {
  source = "./allocation"

  project_id      = var.project_id
  subnet_id       = var.subnet_id
  public_ip_name  = var.public_ip_name
  private_ip_name = var.private_ip_name
  labels          = var.labels
}

###################################
# Boot Disk
###################################

module "disk" {
  source = "./compute-disk"

  project_id           = var.project_id
  disk_name            = var.disk_name
  disk_type            = var.disk_type
  size_gibibytes       = var.disk_size_gibibytes
  block_size_bytes     = var.block_size_bytes
  image_family         = var.image_family
  image_family_parent_id = var.image_family_parent_id
  labels               = var.labels
}

###################################
# Compute Instance
###################################

module "instance" {
  source     = "./compute-instance"
  depends_on = [module.disk, module.allocation, module.service_account]
  project_id    = var.project_id
  subnet_id     = var.subnet_id
  boot_disk_id  = module.disk.disk_id
  instance_name = var.instance_name
  hostname      = var.hostname
  platform = var.platform
  preset   = var.preset
  public_ip_allocation_id  = module.allocation.public_ip_allocation_id
  private_ip_allocation_id = module.allocation.private_ip_allocation_id
  security_group_ids       = var.security_group_ids
  ssh_user_name  = var.ssh_user_name
  ssh_public_key = var.ssh_public_key
  service_account_id = module.service_account.service_account_id
  cluster_id = var.cluster_id
  secondary_disks = var.secondary_disks
  filesystems     = var.filesystems
  gpu_cluster_id = var.gpu_cluster_id
  recovery_policy    = var.recovery_policy
  preemptible        = var.preemptible
  reservation_policy = var.reservation_policy
  stopped            = var.stopped
  install_wireguard = var.install_wireguard
  labels = var.labels
}
