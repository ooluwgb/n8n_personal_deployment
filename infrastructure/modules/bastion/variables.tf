###################################
# Required variables
###################################

variable "project_id" {
  description = "Nebius project ID that owns the bastion disk and instance."
  type        = string
}

variable "subnet_id" {
  description = "VPC subnet ID where the bastion is placed (must be the same VPC/subnet that can reach the K8s private endpoint)."
  type        = string
}

variable "tenant_id" {
  description = "Nebius tenant ID — needed to look up the IAM group for the service account."
  type        = string
}

###################################
# Boot disk configuration
###################################

variable "disk_name" {
  description = "Human-readable name for the boot disk."
  type        = string
  default     = "bastion-boot-disk"
}

variable "disk_type" {
  description = <<-EOT
    Storage type for the boot disk.
      - NETWORK_SSD                  (default – encryption always on)
      - NETWORK_HDD                  (cheaper, slower)
      - NETWORK_SSD_NON_REPLICATED   (high perf, optional encryption)
      - NETWORK_SSD_IO_M3            (highest IOPS, optional encryption)
  EOT
  type        = string
  default     = "NETWORK_SSD"
}

variable "disk_size_gibibytes" {
  description = "Boot disk size in GiB. Default 64 GiB is sufficient for a bastion."
  type        = number
  default     = 64
}

variable "block_size_bytes" {
  description = "Block size in bytes. Must be a power of two between 4096 and 131072."
  type        = number
  default     = 4096
}

variable "image_family" {
  description = <<-EOT
    Image family for the boot disk. Nebius resolves to the latest image.
    Recommended for non-GPU VMs: ubuntu24.04-driverless
  EOT
  type        = string
  default     = "ubuntu24.04-driverless"
}

variable "image_family_parent_id" {
  description = "Parent ID that owns the image family. Null = public catalog."
  type        = string
  default     = null
}

###################################
# Instance identity
###################################

variable "instance_name" {
  description = "Human-readable name for the bastion VM instance."
  type        = string
  default     = "bastion-instance"
}

variable "hostname" {
  description = "Custom hostname for DNS. Null = auto-generated from instance ID."
  type        = string
  default     = null
}

###################################
# Compute resources
###################################

variable "platform" {
  description = "Compute platform: cpu-d3 (AMD Genoa) or cpu-e2 (Intel ICL)."
  type        = string
  default     = "cpu-d3"
}

variable "preset" {
  description = "vCPU + RAM preset. Default: 4vcpu-16gb."
  type        = string
  default     = "4vcpu-16gb"
}

###################################
# Secondary disks
###################################

variable "secondary_disks" {
  description = <<-EOT
    List of secondary (data) disks to attach.
    Each: { id, attach_mode = "READ_WRITE", device_id = null }
  EOT
  type = list(object({
    id          = string
    attach_mode = optional(string, "READ_WRITE")
    device_id   = optional(string)
  }))
  default = []
}

###################################
# Shared filesystems
###################################

variable "filesystems" {
  description = <<-EOT
    List of shared filesystems to attach.
    Each: { id, mount_tag, attach_mode = "READ_WRITE" }
  EOT
  type = list(object({
    id          = string
    mount_tag   = string
    attach_mode = optional(string, "READ_WRITE")
  }))
  default = []
}

###################################
# IP Allocation naming
###################################

variable "public_ip_name" {
  description = "Human-readable name for the permanent public IP allocation."
  type        = string
  default     = "bastion-public-ip"
}

variable "private_ip_name" {
  description = "Human-readable name for the permanent private IP allocation."
  type        = string
  default     = "bastion-private-ip"
}

variable "security_group_ids" {
  description = "List of security group IDs for the bastion NIC. Empty = default SG."
  type        = list(string)
  default     = []
}

###################################
# SSH access
###################################

variable "ssh_user_name" {
  description = "Username for SSH access to the bastion host."
  type        = string
  default     = "bastion"
}

variable "ssh_public_key" {
  description = <<-EOT
    SSH public key. Provide either:
      - key  = "<ssh-rsa ...>"       (inline)
      - path = "~/.ssh/id_rsa.pub"   (file path)
  EOT
  type = object({
    key  = optional(string)
    path = optional(string, "~/.ssh/id_rsa.pub")
  })
  default = {}
}

###################################
# Service account
###################################

variable "service_account_name" {
  description = "Human-readable name for the bastion service account."
  type        = string
  default     = "bastion-sa"
}

variable "service_account_description" {
  description = "Description for the bastion service account."
  type        = string
  default     = "Service account for the bastion host — used by Nebius CLI and kubectl."
}

variable "auth_key_expires_at" {
  description = "Absolute expiration timestamp for the bastion SA auth key in RFC3339 format (for example, 2026-06-30T23:59:59Z)."
  type        = string
}

variable "iam_group_name" {
  description = "Name of the IAM group to add the service account to."
  type        = string
  default     = "editors"
}

###################################
# Kubernetes cluster
###################################

variable "cluster_id" {
  description = "MK8s cluster ID for automatic kubeconfig setup via cloud-init."
  type        = string
}

###################################
# GPU cluster
###################################

variable "gpu_cluster_id" {
  description = "GPU cluster ID for InfiniBand interconnect. Null = not applicable."
  type        = string
  default     = null
}

###################################
# Recovery policy
###################################

variable "recovery_policy" {
  description = "RECOVER (auto-restart on failure) or FAIL (stop on failure)."
  type        = string
  default     = "RECOVER"
}

###################################
# Preemptible VM
###################################

variable "preemptible" {
  description = <<-EOT
    Enable preemptible (spot) mode. Null = regular instance.
    Example: { on_preemption = "STOP", priority = 3 }
  EOT
  type = object({
    on_preemption = optional(string, "STOP")
    priority      = optional(number, 3)
  })
  default = null
}

###################################
# Reservation policy
###################################

variable "reservation_policy" {
  description = <<-EOT
    Capacity block reservation policy. Null = on-demand.
    Example: { policy = "AUTO", reservation_ids = ["res-123"] }
  EOT
  type = object({
    policy          = optional(string, "AUTO")
    reservation_ids = optional(list(string))
  })
  default = null
}

###################################
# Instance state
###################################

variable "stopped" {
  description = "When true, the instance is created/kept in a stopped state."
  type        = bool
  default     = null
}

###################################
# Optional features
###################################

variable "install_wireguard" {
  description = "Install and configure WireGuard VPN with web UI on port 5000."
  type        = bool
  default     = false
}

###################################
# Resource labels
###################################

variable "labels" {
  description = "Key/value labels for both the disk and instance resources."
  type        = map(string)
  default     = {}
}
