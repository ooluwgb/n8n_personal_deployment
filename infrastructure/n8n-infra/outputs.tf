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

###################################
# GitHub Runner Outputs
###################################

output "github_runner_instance_id" {
  description = "Compute instance ID of the GitHub self-hosted runner VM."
  value       = try(module.github_runner[0].instance_id, null)
}

output "github_runner_private_ip" {
  description = "Private IP address of the GitHub self-hosted runner VM."
  value       = try(module.github_runner[0].private_ip, null)
}

output "github_runner_public_ip" {
  description = "Public IP address of the GitHub self-hosted runner VM (if enabled)."
  value       = try(module.github_runner[0].public_ip, null)
}

output "github_runner_service_account_id" {
  description = "Service account ID attached to the GitHub self-hosted runner VM."
  value       = try(module.github_runner[0].service_account_id, null)
}

output "github_runner_name" {
  description = "Runner name registered in GitHub."
  value       = try(module.github_runner[0].runner_name, null)
}
