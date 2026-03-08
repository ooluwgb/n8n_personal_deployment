###################################
# Disk identity
###################################

output "disk_id" {
  description = "The unique ID of the compute disk (used when attaching to a VM instance)."
  value       = nebius_compute_v1_disk.this.id
}

output "disk_name" {
  description = "The human-readable name of the disk."
  value       = nebius_compute_v1_disk.this.name
}

###################################
# Disk status
###################################

output "disk_status" {
  description = "Full status object (state, size, attachments, source image info)."
  value       = nebius_compute_v1_disk.this.status
}

output "disk_state" {
  description = "Current lifecycle state: CREATING, READY, UPDATING, DELETING, ERROR, or BROKEN."
  value       = try(nebius_compute_v1_disk.this.status.state, null)
}

###################################
# Size & type (for downstream use)
###################################

output "disk_size_bytes" {
  description = "Actual provisioned disk size in bytes (read from status)."
  value       = try(nebius_compute_v1_disk.this.status.size_bytes, null)
}

output "disk_type" {
  description = "The disk storage type (NETWORK_SSD, NETWORK_HDD, etc.)."
  value       = nebius_compute_v1_disk.this.type
}

###################################
# Source image
###################################

output "source_image_id" {
  description = "ID of the image used to create the disk (resolved from image family)."
  value       = try(nebius_compute_v1_disk.this.status.source_image_id, null)
}

###################################
# Attachments
###################################

output "read_write_attachment" {
  description = "Instance ID that currently owns the disk for read-write access."
  value       = try(nebius_compute_v1_disk.this.status.read_write_attachment, null)
}
