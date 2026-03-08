###################################
# Required variables
###################################

variable "project_id" {
  description = "Nebius project ID that owns this cluster."
  type        = string
}

variable "cluster_name" {
  description = "Human-readable name for the MK8s cluster. Only lowercase letters, numbers, and dashes allowed. No spaces. Max 30 characters."
  type        = string
  default     = "n8n-terraform-deployment"

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,28}[a-z0-9])?$", var.cluster_name))
    error_message = "Cluster name must be 1-30 characters, contain only lowercase letters (a-z), numbers (0-9), and dashes (-). No spaces. Must start and end with a letter or number."
  }
}

variable "subnet_id" {
  description = "VPC subnet ID where control plane instances are placed."
  type        = string
}

###################################
# Control plane configuration
###################################

variable "cluster_version" {
  description = "Desired Kubernetes version (format: '<major>.<minor>', e.g. '1.32')."
  type        = string
  default     = "1.32"
}

variable "etcd_cluster_size" {
  description = <<-EOT
    Number of etcd instances backing the control plane.
    - 1 = non-HA (dev/test)
    - 3 = HA (tolerates 1 failure, recommended for production)
  EOT
  type        = number
  default     = 3
}

variable "enable_public_endpoint" {
  description = "When true, creates a publicly-accessible Kubernetes API endpoint in addition to the private one."
  type        = bool
  default     = false
}

variable "enable_audit_logs" {
  description = "When true, pushes Kubernetes audit logs to the Nebius Logs service (visible in the console)."
  type        = bool
  default     = true
}

###################################
# Kubernetes networking
###################################

variable "service_cidrs" {
  description = <<-EOT
    List of CIDR blocks for Kubernetes Service ClusterIP allocation.
    Only one value is currently supported. Allowed prefix length: /12 to /28.
    Leave null to use the platform default (auto-allocated from the subnet).

    Example: ["10.96.0.0/16"]
  EOT
  type        = list(string)
  default     = null
}

###################################
# Resource labels
###################################

variable "labels" {
  description = "Key/value labels attached to the cluster resource (for filtering, billing, etc.)."
  type        = map(string)
  default     = {}
}
