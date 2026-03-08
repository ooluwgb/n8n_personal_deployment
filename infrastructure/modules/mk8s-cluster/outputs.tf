###################################
# Cluster identity
###################################

output "cluster_id" {
  description = "The unique ID of the MK8s cluster (used as parent_id for node groups)."
  value       = nebius_mk8s_v1_cluster.main.id
}

output "cluster_name" {
  description = "The human-readable name of the cluster."
  value       = nebius_mk8s_v1_cluster.main.name
}

###################################
# Cluster status
###################################

output "cluster_status" {
  description = "Full status object (state, endpoints, etcd size, version, CA cert)."
  value       = nebius_mk8s_v1_cluster.main.status
}

output "cluster_state" {
  description = "Current lifecycle state: PROVISIONING, RUNNING, or DELETING."
  value       = try(nebius_mk8s_v1_cluster.main.status.state, null)
}

###################################
# Endpoints (for kubeconfig / CI)
###################################

output "private_endpoint" {
  description = "Private DNS name or IP for the Kubernetes API (accessible from within the VPC)."
  value       = try(nebius_mk8s_v1_cluster.main.status.control_plane.endpoints.private_endpoint, null)
}

output "public_endpoint" {
  description = "Public DNS name or IP for the Kubernetes API (null if public endpoint is disabled)."
  value       = try(nebius_mk8s_v1_cluster.main.status.control_plane.endpoints.public_endpoint, null)
}

###################################
# TLS
###################################

output "cluster_ca_certificate" {
  description = "PEM-encoded CA certificate for TLS connections to the Kubernetes API."
  value       = try(nebius_mk8s_v1_cluster.main.status.control_plane.auth.cluster_ca_certificate, null)
  sensitive   = true
}
