###################################
# Required variables
###################################

variable "project_id" {
  description = "Nebius project ID that owns this disk."
  type        = string
}

###################################
# Disk identity
###################################

variable "disk_name" {
  description = "Human-readable name for the boot disk."
  type        = string
  default     = "bastion-boot-disk"

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$", var.disk_name))
    error_message = "Disk name must be 1-63 characters, lowercase letters, numbers, and dashes only. Must start and end with a letter or number."
  }
}

###################################
# Disk type & size
###################################

variable "disk_type" {
  description = <<-EOT
    Storage type for the disk. Determines performance and cost.
      - NETWORK_SSD                  (default – encryption always on)
      - NETWORK_HDD                  (cheaper, slower, no encryption)
      - NETWORK_SSD_NON_REPLICATED   (high perf, optional encryption)
      - NETWORK_SSD_IO_M3            (highest IOPS, optional encryption)
  EOT
  type        = string
  default     = "NETWORK_SSD"

  validation {
    condition = contains([
      "NETWORK_SSD",
      "NETWORK_HDD",
      "NETWORK_SSD_NON_REPLICATED",
      "NETWORK_SSD_IO_M3",
    ], var.disk_type)
    error_message = "disk_type must be one of: NETWORK_SSD, NETWORK_HDD, NETWORK_SSD_NON_REPLICATED, NETWORK_SSD_IO_M3."
  }
}

variable "size_gibibytes" {
  description = <<-EOT
    Disk size in GiB.
    SSD allocation unit is 32 GiB — sizes are rounded up to the nearest unit.
    For a bastion host 64 GiB is typically sufficient.
    For maximum SSD performance across all metrics, use 1280 GiB or more.
  EOT
  type        = number
  default     = 64

  validation {
    condition     = var.size_gibibytes >= 1
    error_message = "Disk size must be at least 1 GiB."
  }
}

variable "block_size_bytes" {
  description = <<-EOT
    Block size in bytes. Must be a power of two between 4096 (4 KiB) and 131072 (128 KiB).
    Default is 4096 bytes (4 KiB).
  EOT
  type        = number
  default     = 4096

  validation {
    condition     = contains([4096, 8192, 16384, 32768, 65536, 131072], var.block_size_bytes)
    error_message = "block_size_bytes must be a power of two between 4096 and 131072."
  }
}

###################################
# Source image
###################################

variable "image_family" {
  description = "Image family name for the boot disk."

  type        = string
  default     = "ubuntu24.04-driverless"
}

variable "image_family_parent_id" {
  description = <<-EOT
    Parent ID (project/folder) that owns the image family.
    Leave null to use the community/public image catalog.
  EOT
  type        = string
  default     = null
}

###################################
# Resource labels
###################################

variable "labels" {
  description = "Key/value labels attached to the disk resource (for filtering, billing, etc.)."
  type        = map(string)
  default     = {}
}
