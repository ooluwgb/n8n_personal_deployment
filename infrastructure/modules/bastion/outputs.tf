###################################
# Service Account outputs
###################################

output "service_account_id" {
  description = "The unique ID of the bastion service account."
  value       = module.service_account.service_account_id
}

output "service_account_name" {
  description = "The human-readable name of the service account."
  value       = module.service_account.service_account_name
}

output "service_account_active" {
  description = "Whether the service account is active."
  value       = module.service_account.service_account_active
}

output "auth_public_key_id" {
  description = "The unique ID of the SA auth public key."
  value       = module.service_account.auth_public_key_id
}

output "auth_public_key_fingerprint" {
  description = "Fingerprint of the SA public key."
  value       = module.service_account.auth_public_key_fingerprint
}

###################################
# Disk outputs
###################################

output "disk_id" {
  description = "The unique ID of the bastion boot disk."
  value       = module.disk.disk_id
}

output "disk_name" {
  description = "The human-readable name of the boot disk."
  value       = module.disk.disk_name
}

output "disk_state" {
  description = "Current disk lifecycle state."
  value       = module.disk.disk_state
}

###################################
# IP Allocation outputs
###################################

output "public_ip_allocation_id" {
  description = "The unique ID of the permanent public IP allocation."
  value       = module.allocation.public_ip_allocation_id
}

output "public_ip_address" {
  description = "The allocated static public IPv4 address (CIDR notation)."
  value       = module.allocation.public_ip_address
}

output "public_ip_state" {
  description = "State of the public IP allocation (CREATING, ALLOCATED, ASSIGNED, DELETING)."
  value       = module.allocation.public_ip_state
}

output "private_ip_allocation_id" {
  description = "The unique ID of the permanent private IP allocation."
  value       = module.allocation.private_ip_allocation_id
}

output "private_ip_address" {
  description = "The allocated static private IPv4 address (CIDR notation)."
  value       = module.allocation.private_ip_address
}

output "private_ip_state" {
  description = "State of the private IP allocation (CREATING, ALLOCATED, ASSIGNED, DELETING)."
  value       = module.allocation.private_ip_state
}

###################################
# Instance outputs
###################################

output "instance_id" {
  description = "The unique ID of the bastion compute instance."
  value       = module.instance.instance_id
}

output "instance_name" {
  description = "The human-readable name of the bastion instance."
  value       = module.instance.instance_name
}

output "instance_state" {
  description = "Current instance lifecycle state."
  value       = module.instance.instance_state
}

output "instance_status" {
  description = "Full instance status object."
  value       = module.instance.instance_status
}

###################################
# Networking
###################################

output "private_ip" {
  description = "Private IPv4 address of the bastion."
  value       = module.instance.private_ip
}

output "public_ip" {
  description = "Public IPv4 address of the bastion."
  value       = module.instance.public_ip
}

output "network_interfaces" {
  description = "Full network interface status objects."
  value       = module.instance.network_interfaces
}

###################################
# Storage
###################################

output "secondary_disk_count" {
  description = "Number of secondary disks attached."
  value       = module.instance.secondary_disk_count
}

output "filesystem_count" {
  description = "Number of shared filesystems attached."
  value       = module.instance.filesystem_count
}

###################################
# Reservation
###################################

output "reservation_id" {
  description = "Capacity block reservation ID (null if on-demand)."
  value       = module.instance.reservation_id
}

###################################
# Timestamps
###################################

output "created_at" {
  description = "Instance creation timestamp (ISO 8601)."
  value       = module.instance.created_at
}

output "updated_at" {
  description = "Instance last update timestamp (ISO 8601)."
  value       = module.instance.updated_at
}

###################################
# SSH helpers
###################################

output "ssh_command" {
  description = "Ready-to-use SSH command to connect to the bastion."
  value       = module.instance.ssh_command
}

output "ssh_tunnel_command" {
  description = "SSH tunnel command to forward K8s API port 6443 through the bastion."
  value       = module.instance.ssh_tunnel_command
}

output "ssh_config_snippet" {
  description = "Snippet for ~/.ssh/config for ProxyJump access."
  value       = module.instance.ssh_config_snippet
}
