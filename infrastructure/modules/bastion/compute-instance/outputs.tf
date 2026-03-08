###################################
# Instance identity
###################################

output "instance_id" {
  description = "The unique ID of the bastion compute instance."
  value       = nebius_compute_v1_instance.this.id
}

output "instance_name" {
  description = "The human-readable name of the bastion instance."
  value       = nebius_compute_v1_instance.this.name
}

###################################
# Instance status
###################################

output "instance_status" {
  description = "Full status object (state, network interfaces, etc.)."
  value       = nebius_compute_v1_instance.this.status
}

output "instance_state" {
  description = "Current lifecycle state: CREATING, RUNNING, STOPPED, ERROR, etc."
  value       = try(nebius_compute_v1_instance.this.status.state, null)
}

###################################
# Networking
###################################

output "private_ip" {
  description = "Private IPv4 address of the bastion (for SSH ProxyJump targets and cluster access)."
  value       = try(nebius_compute_v1_instance.this.status.network_interfaces[0].ip_address.address, null)
}

output "public_ip" {
  description = "Public IPv4 address of the bastion (used for SSH access from your laptop)."
  value       = try(trimsuffix(nebius_compute_v1_instance.this.status.network_interfaces[0].public_ip_address.address, "/32"), null)
}

output "network_interfaces" {
  description = "Full list of network interface status objects (IPs, MACs, FQDNs, security groups)."
  value       = try(nebius_compute_v1_instance.this.status.network_interfaces, [])
}

###################################
# Attached storage
###################################

output "secondary_disk_count" {
  description = "Number of secondary disks attached to the instance."
  value       = length(var.secondary_disks)
}

output "filesystem_count" {
  description = "Number of shared filesystems attached to the instance."
  value       = length(var.filesystems)
}

###################################
# Reservation
###################################

output "reservation_id" {
  description = "Capacity block reservation ID the instance is running in (null if on-demand)."
  value       = try(nebius_compute_v1_instance.this.status.reservation_id, null)
}

###################################
# Timestamps
###################################

output "created_at" {
  description = "Timestamp when the instance was created (ISO 8601)."
  value       = nebius_compute_v1_instance.this.created_at
}

output "updated_at" {
  description = "Timestamp when the instance was last updated (ISO 8601)."
  value       = nebius_compute_v1_instance.this.updated_at
}

###################################
# SSH connection helpers
###################################

output "ssh_command" {
  description = "Ready-to-use SSH command to connect to the bastion."
  value       = "ssh ${var.ssh_user_name}@${try(trimsuffix(nebius_compute_v1_instance.this.status.network_interfaces[0].public_ip_address.address, "/32"), "<pending>")}"
}

output "ssh_tunnel_command" {
  description = "SSH tunnel command to forward the K8s API server port (6443) through the bastion."
  value       = var.cluster_id != null ? "ssh -L 6443:<CLUSTER_PRIVATE_ENDPOINT>:6443 ${var.ssh_user_name}@${try(trimsuffix(nebius_compute_v1_instance.this.status.network_interfaces[0].public_ip_address.address, "/32"), "<pending>")} -N" : "No cluster_id provided — tunnel not applicable."
}

###################################
# SSH config snippet
###################################

output "ssh_config_snippet" {
  description = "Snippet to add to ~/.ssh/config for ProxyJump access through the bastion."
  value       = <<-EOT
    Host bastion
        HostName ${try(trimsuffix(nebius_compute_v1_instance.this.status.network_interfaces[0].public_ip_address.address, "/32"), "<pending>")}
        User ${var.ssh_user_name}
        IdentityFile ~/.ssh/id_rsa

    Host target-*
        User ubuntu
        IdentityFile ~/.ssh/id_rsa
        ProxyJump bastion
  EOT
}
