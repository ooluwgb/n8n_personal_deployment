###################################
# Public IP outputs
###################################

output "public_ip_allocation_id" {
  description = "The unique ID of the public IP allocation."
  value       = nebius_vpc_v1_allocation.public_ip.id
}

output "public_ip_address" {
  description = "The allocated public IPv4 address."
  value       = try(nebius_vpc_v1_allocation.public_ip.status.details.allocated_cidr, null)
}

output "public_ip_state" {
  description = "Current state of the public IP allocation (CREATING, ALLOCATED, ASSIGNED, DELETING)."
  value       = try(nebius_vpc_v1_allocation.public_ip.status.state, null)
}

###################################
# Private IP outputs
###################################

output "private_ip_allocation_id" {
  description = "The unique ID of the private IP allocation."
  value       = nebius_vpc_v1_allocation.private_ip.id
}

output "private_ip_address" {
  description = "The allocated private IPv4 address."
  value       = try(nebius_vpc_v1_allocation.private_ip.status.details.allocated_cidr, null)
}

output "private_ip_state" {
  description = "Current state of the private IP allocation (CREATING, ALLOCATED, ASSIGNED, DELETING)."
  value       = try(nebius_vpc_v1_allocation.private_ip.status.state, null)
}
