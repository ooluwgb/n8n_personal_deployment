output "instance_id" {
  description = "Compute instance ID of the GitHub runner VM."
  value       = nebius_compute_v1_instance.runner.id
}

output "instance_name" {
  description = "Runner VM instance name."
  value       = nebius_compute_v1_instance.runner.name
}

output "private_ip" {
  description = "Private IPv4 address of the runner VM."
  value       = try(nebius_compute_v1_instance.runner.status.network_interfaces[0].ip_address.address, null)
}

output "public_ip" {
  description = "Public IPv4 address of the runner VM (null when enable_public_ip=false)."
  value       = try(trimsuffix(nebius_compute_v1_instance.runner.status.network_interfaces[0].public_ip_address.address, "/32"), null)
}

output "service_account_id" {
  description = "Service account ID attached to the runner VM."
  value       = nebius_iam_v1_service_account.runner.id
}

output "runner_name" {
  description = "Runner name registered in GitHub."
  value       = local.runner_name
}

output "runner_labels" {
  description = "Runner labels registered in GitHub."
  value       = var.github_runner_labels
}
