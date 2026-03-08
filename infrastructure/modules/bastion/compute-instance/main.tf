terraform {
  required_providers {
    nebius = {
      source = "terraform-provider.storage.eu-north1.nebius.cloud/nebius/nebius"
    }
  }
}

###################################
# Locals
###################################

locals {
  ssh_public_key = var.ssh_public_key.key != null ? var.ssh_public_key.key : (
    fileexists(var.ssh_public_key.path) ? file(var.ssh_public_key.path) : null
  )
}

###################################
# Bastion – Compute Instance
###################################
#
# Creates a bastion (jump host) VM with:
#   - A public IP for SSH access from your laptop
#   - A private IP in the same subnet as the K8s cluster
#   - cloud-init provisioning: SSH user, kubectl, Nebius CLI
#   - Optional: WireGuard VPN, secondary disks, shared
#     filesystems, GPU cluster, preemptible mode
#
# The boot disk is created separately via the compute-disk
# module and attached here as an existing disk.
#
# Every optional block defaults to null so the resource
# behaves like a minimal bastion when extras are omitted.
###################################

resource "nebius_compute_v1_instance" "this" {
  parent_id = var.project_id
  name      = var.instance_name
  hostname  = var.hostname
  labels    = var.labels

  ###################################
  # Boot disk (from compute-disk module)
  ###################################
  boot_disk = {
    attach_mode   = "READ_WRITE"
    existing_disk = {
      id = var.boot_disk_id
    }
  }

  ###################################
  # Secondary disks
  ###################################
  secondary_disks = length(var.secondary_disks) > 0 ? [
    for disk in var.secondary_disks : {
      attach_mode   = try(disk.attach_mode, "READ_WRITE")
      device_id     = try(disk.device_id, null)
      existing_disk = {
        id = disk.id
      }
    }
  ] : null

  ###################################
  # Shared filesystems
  ###################################
  filesystems = length(var.filesystems) > 0 ? [
    for fs in var.filesystems : {
      attach_mode         = try(fs.attach_mode, "READ_WRITE")
      mount_tag           = fs.mount_tag
      existing_filesystem = {
        id = fs.id
      }
    }
  ] : null

  ###################################
  # Networking
  ###################################
  network_interfaces = [
    {
      name      = "eth0"
      subnet_id = var.subnet_id

      # Private IP — pin to a static allocation when provided
      ip_address = var.private_ip_allocation_id != null ? {
        allocation_id = var.private_ip_allocation_id
      } : {}

      # Public IP — pin to a static allocation when provided
      public_ip_address = var.public_ip_allocation_id != null ? {
        allocation_id = var.public_ip_allocation_id
        static        = true
      } : {}

      # Security groups — use default network SG when not specified
      security_groups = length(var.security_group_ids) > 0 ? [
        for sg_id in var.security_group_ids : { id = sg_id }
      ] : null
    }
  ]

  ###################################
  # Compute resources
  ###################################
  resources = {
    platform = var.platform
    preset   = var.preset
  }

  ###################################
  # GPU cluster (null when not needed)
  ###################################
  gpu_cluster = var.gpu_cluster_id != null ? {
    id = var.gpu_cluster_id
  } : null

  ###################################
  # IAM
  ###################################
  service_account_id = var.service_account_id

  ###################################
  # Recovery policy
  ###################################
  recovery_policy = var.recovery_policy

  ###################################
  # Preemptible VM
  ###################################
  preemptible = var.preemptible != null ? {
    on_preemption = try(var.preemptible.on_preemption, "STOP")
    priority      = try(var.preemptible.priority, 3)
  } : null

  ###################################
  # Reservation policy
  ###################################
  reservation_policy = var.reservation_policy != null ? {
    policy          = try(var.reservation_policy.policy, "AUTO")
    reservation_ids = try(var.reservation_policy.reservation_ids, null)
  } : null

  ###################################
  # Stopped state
  ###################################
  stopped = var.stopped

  ###################################
  # Cloud-init
  ###################################
  cloud_init_user_data = templatefile(
    "${path.module}/templates/bastion-cloud-init.tftpl",
    {
      ssh_user_name  = var.ssh_user_name
      ssh_public_key = local.ssh_public_key
      project_id     = var.project_id
      cluster_id     = var.cluster_id
    }
  )
}
