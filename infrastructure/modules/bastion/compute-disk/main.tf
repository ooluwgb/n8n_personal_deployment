terraform {
  required_providers {
    nebius = {
      source = "terraform-provider.storage.eu-north1.nebius.cloud/nebius/nebius"
    }
  }
}

###################################
# Bastion – Boot Disk
###################################
# Creates a compute disk for the bastion host VM.
###################################

resource "nebius_compute_v1_disk" "this" {
  parent_id = var.project_id
  name      = var.disk_name
  labels    = var.labels
  type      = var.disk_type

  size_gibibytes = var.size_gibibytes
  block_size_bytes = var.block_size_bytes
  source_image_family = {
    image_family = var.image_family
    parent_id    = var.image_family_parent_id
  }
}
