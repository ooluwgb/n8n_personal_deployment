###################################
# Node Groups — YAML-driven module
###################################
#
# This module creates MK8s node groups from a YAML
# configuration file.  Only "name" and "node_group_type"
# are required per entry; every other field falls back
# to defaults defined in locals.
#
# The YAML file lives in the ROOT module (not here).
# Pass its path via the config_file variable.
###################################

###################################
# Required — from root module
###################################

variable "cluster_id" {
  description = "MK8s cluster ID (parent_id for every node group)."
  type        = string
}

variable "subnet_id" {
  description = "Default VPC subnet ID for node network interfaces."
  type        = string
}

variable "config_file" {
  description = "Absolute path to the node-groups YAML configuration file (lives in the root module)."
  type        = string
}

###################################
# Optional — from root module
###################################

variable "k8s_version" {
  description = "Kubernetes version for all node groups (format: major.minor)."
  type        = string
  default     = "1.32"
}

variable "service_account_id" {
  description = "Default service account ID for node instances (registry/API access)."
  type        = string
  default     = null
}
