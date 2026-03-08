terraform {
  required_providers {
    nebius = {
      source = "terraform-provider.storage.eu-north1.nebius.cloud/nebius/nebius"
    }
  }
}

###################################
# Bastion — IP Allocations
###################################
# Creates permanent (static) IP allocations for the bastion:
###################################

###################################
# Public IP Allocation
###################################

resource "nebius_vpc_v1_allocation" "public_ip" {
  parent_id = var.project_id
  name      = var.public_ip_name
  labels    = var.labels

  ipv4_public = {
    subnet_id = var.subnet_id
  }
}

###################################
# Private IP Allocation
###################################

resource "nebius_vpc_v1_allocation" "private_ip" {
  parent_id = var.project_id
  name      = var.private_ip_name
  labels    = var.labels

  ipv4_private = {
    subnet_id = var.subnet_id
  }
}
