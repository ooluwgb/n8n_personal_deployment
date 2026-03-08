###################################
# Identity
###################################

output "node_group_ids" {
  description = "Map of logical name to node group resource ID."
  value       = { for k, v in nebius_mk8s_v1_node_group.this : k => v.id }
}

output "node_group_names" {
  description = "Map of logical name to node group display name."
  value       = { for k, v in nebius_mk8s_v1_node_group.this : k => v.name }
}

###################################
# Status
###################################

output "node_group_statuses" {
  description = "Map of logical name to node group status object."
  value       = { for k, v in nebius_mk8s_v1_node_group.this : k => v.status }
}

###################################
# Node group type (for downstream logic)
###################################

output "node_group_types" {
  description = "Map of logical name to node group type (application/database)."
  value       = { for k, v in local.node_groups : k => v.node_group_type }
}

output "database_node_groups" {
  description = "List of logical names that have type 'database'."
  value       = [for k, v in local.node_groups : k if v.node_group_type == "database"]
}

output "has_database_nodes" {
  description = "True when at least one node group has type 'database'."
  value       = length([for k, v in local.node_groups : k if v.node_group_type == "database"]) > 0
}
