###################################
# Required variables
###################################

variable "project_id" {
  description = "Nebius project ID that owns this instance."
  type        = string
}

variable "subnet_id" {
  description = "VPC subnet ID where the bastion is placed (must be the same VPC/subnet that can reach the K8s private endpoint)."
  type        = string
}

variable "boot_disk_id" {
  description = "ID of the boot disk created by the compute-disk module."
  type        = string
}

###################################
# Instance identity
###################################

variable "instance_name" {
  description = "Human-readable name for the bastion VM instance."
  type        = string
  default     = "bastion-instance"

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$", var.instance_name))
    error_message = "Instance name must be 1-63 characters, lowercase letters, numbers, and dashes only. Must start and end with a letter or number."
  }
}

variable "hostname" {
  description = <<-EOT
    Custom hostname for the instance.
    Used to generate the default DNS record:
      <hostname>.<network_id>.compute.internal
    If null, defaults to <instance_id>.<network_id>.compute.internal.
  EOT
  type        = string
  default     = null
}

###################################
# Compute resources
###################################

variable "platform" {
  description = <<-EOT
    Compute platform for the bastion VM.
    Non-GPU platforms:
      - cpu-d3  (AMD EPYC Genoa) — recommended
      - cpu-e2  (Intel Ice Lake)
  EOT
  type        = string
  default     = "cpu-d3"
}

variable "preset" {
  description = <<-EOT
    Compute resource preset (vCPU + RAM combination).
    For a bastion host, 4vcpu-16gb is typically sufficient.
    See: https://docs.nebius.com/compute/virtual-machines/types
  EOT
  type        = string
  default     = "4vcpu-16gb"
}

###################################
# Secondary disks
###################################

variable "secondary_disks" {
  description = <<-EOT
    List of secondary (data) disks to attach to the instance.
    Each entry requires:
      - id          : ID of an existing disk to attach
      - attach_mode : READ_WRITE (default) or READ_ONLY
      - device_id   : Optional user-defined ID (use /dev/disk/by-id/virtio-<device_id>)

    The disk is preserved when the instance is deleted (detached, not destroyed).
    Pass [] to attach no secondary disks.
  EOT
  type = list(object({
    id          = string
    attach_mode = optional(string, "READ_WRITE")
    device_id   = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for d in var.secondary_disks : contains(["READ_WRITE", "READ_ONLY"], d.attach_mode)
    ])
    error_message = "Each secondary disk attach_mode must be READ_WRITE or READ_ONLY."
  }
}

###################################
# Shared filesystems
###################################

variable "filesystems" {
  description = <<-EOT
    List of shared filesystems to attach to the instance.
    Each entry requires:
      - id          : ID of an existing filesystem
      - mount_tag   : User-defined identifier used as device in mount command
      - attach_mode : READ_WRITE (default) or READ_ONLY

    Example:
      filesystems = [{
        id          = module.shared_fs.filesystem_id
        mount_tag   = "data"
        attach_mode = "READ_WRITE"
      }]
  EOT
  type = list(object({
    id          = string
    mount_tag   = string
    attach_mode = optional(string, "READ_WRITE")
  }))
  default = []

  validation {
    condition = alltrue([
      for fs in var.filesystems : contains(["READ_WRITE", "READ_ONLY"], fs.attach_mode)
    ])
    error_message = "Each filesystem attach_mode must be READ_WRITE or READ_ONLY."
  }
}

###################################
# Networking
###################################

variable "public_ip_allocation_id" {
  description = <<-EOT
    ID of a public IP allocation for a stable bastion IP.
    When set, the public IP persists even if the VM is deleted/recreated.
    Null = ephemeral public IP.
  EOT
  type        = string
  default     = null
}

variable "private_ip_allocation_id" {
  description = <<-EOT
    ID of a private IP allocation for a stable bastion private IP.
    When set, the private IP persists even if the VM is deleted/recreated.
    Null = auto-assigned private IP.
  EOT
  type        = string
  default     = null
}

variable "security_group_ids" {
  description = <<-EOT
    List of security group IDs to attach to the bastion's network interface.
    If empty, the default security group for the network is used.
  EOT
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
    SSH public key for bastion access. Provide either:
      - key  = "<ssh-rsa ...>"       (inline key string)
      - path = "~/.ssh/id_rsa.pub"   (path to key file)
    At least one must be valid.
  EOT
  type = object({
    key  = optional(string)
    path = optional(string, "~/.ssh/id_rsa.pub")
  })
  default = {}

  validation {
    condition     = var.ssh_public_key.key != null || fileexists(var.ssh_public_key.path)
    error_message = "SSH public key must be provided via 'key' (inline) or 'path' (file at ${var.ssh_public_key.path})."
  }
}

###################################
# IAM
###################################

variable "service_account_id" {
  description = <<-EOT
    Service account ID attached to the bastion instance.
    Used for Nebius CLI authentication and kubectl access.
    If null, the instance runs without a service account.
  EOT
  type        = string
  default     = null
}

###################################
# Kubernetes cluster
###################################

variable "cluster_id" {
  description = <<-EOT
    MK8s cluster ID for automatic kubeconfig setup via cloud-init.
    Cloud-init will run:
      nebius mk8s cluster get-credentials --id <cluster_id> --internal
  EOT
  type        = string
}

###################################
# GPU cluster
###################################

variable "gpu_cluster_id" {
  description = <<-EOT
    ID of a GPU cluster to join via NVIDIA InfiniBand.
    Can only be set at instance creation time.
    Leave null for non-GPU bastion hosts.
    See: https://docs.nebius.com/compute/clusters/gpu
  EOT
  type        = string
  default     = null
}

###################################
# Recovery policy
###################################

variable "recovery_policy" {
  description = <<-EOT
    How the instance recovers from host failures.
      - RECOVER  (default) — VM is automatically restarted
      - FAIL     — VM is stopped and not restarted
  EOT
  type        = string
  default     = "RECOVER"

  validation {
    condition     = contains(["RECOVER", "FAIL"], var.recovery_policy)
    error_message = "recovery_policy must be RECOVER or FAIL."
  }
}

###################################
# Preemptible VM
###################################

variable "preemptible" {
  description = <<-EOT
    Set to enable preemptible (spot) mode for cost savings.
    When preempted, the VM is stopped (not deleted).

    Example:
      preemptible = {
        on_preemption = "STOP"
        priority      = 3       # 1 (lowest) to 5 (highest)
      }

    Leave null for a regular (non-preemptible) instance.
    See: https://docs.nebius.com/compute/virtual-machines/preemptible
  EOT
  type = object({
    on_preemption = optional(string, "STOP")
    priority      = optional(number, 3)
  })
  default = null

  validation {
    condition     = var.preemptible == null || contains(["STOP"], try(var.preemptible.on_preemption, "STOP"))
    error_message = "preemptible.on_preemption must be STOP."
  }

  validation {
    condition     = var.preemptible == null || (try(var.preemptible.priority, 3) >= 1 && try(var.preemptible.priority, 3) <= 5)
    error_message = "preemptible.priority must be between 1 and 5."
  }
}

###################################
# Reservation policy
###################################

variable "reservation_policy" {
  description = <<-EOT
    Capacity block reservation policy.
      - AUTO   — try reservations first, fall back to on-demand
      - FORBID — on-demand only (cannot specify reservation_ids)
      - STRICT — reservations only, fail if none available

    Example:
      reservation_policy = {
        policy          = "AUTO"
        reservation_ids = ["reservation-abc123"]
      }

    Leave null to use default behaviour (on-demand).
  EOT
  type = object({
    policy          = optional(string, "AUTO")
    reservation_ids = optional(list(string))
  })
  default = null

  validation {
    condition     = var.reservation_policy == null || contains(["AUTO", "FORBID", "STRICT"], try(var.reservation_policy.policy, "AUTO"))
    error_message = "reservation_policy.policy must be AUTO, FORBID, or STRICT."
  }
}

###################################
# Instance state
###################################

variable "stopped" {
  description = <<-EOT
    When true, the instance is created in a stopped state (or stopped if already running).
    Useful for pre-provisioning without incurring compute costs.
    Default is null (instance starts normally).
  EOT
  type        = bool
  default     = null
}

###################################
# Optional features
###################################

variable "install_wireguard" {
  description = "When true, cloud-init installs and configures WireGuard VPN with a web UI on port 5000."
  type        = bool
  default     = false
}

###################################
# Resource labels
###################################

variable "labels" {
  description = "Key/value labels attached to the instance resource (for filtering, billing, etc.)."
  type        = map(string)
  default     = {}
}
