###################################
# Cluster Outputs
###################################

output "cluster_id" {
  description = "MK8s cluster ID."
  value       = module.cluster.cluster_id
}

###################################
# Bastion Outputs
###################################

output "bastion_public_ip" {
  description = "Public IP address of the bastion host."
  value       = module.bastion.public_ip_address
}

output "bastion_private_ip" {
  description = "Private IP address of the bastion host."
  value       = module.bastion.private_ip_address
}

output "bastion_instance_id" {
  description = "Compute instance ID of the bastion host."
  value       = module.bastion.instance_id
}

output "bastion_service_account_id" {
  description = "Service account ID created for the bastion host."
  value       = module.bastion.service_account_id
}

output "bastion_ssh_command" {
  description = "Ready-to-use SSH command for the bastion."
  value       = module.bastion.ssh_command
}
