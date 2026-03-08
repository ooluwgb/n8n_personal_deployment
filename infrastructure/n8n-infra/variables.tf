###################################
# Nebius Provider Authentication
# Requuired variable for CI/CD
# environment variables:
#   TF_VAR_nb_service_account_id
#   TF_VAR_nb_public_key_id
#   TF_VAR_nb_private_key_file
###################################

variable "nb_service_account_id" {
  description = "Nebius service account ID for Terraform provider authentication."
  type        = string
  sensitive   = true
}

variable "nb_public_key_id" {
  description = "Nebius authorized public key ID for Terraform provider authentication."
  type        = string
  sensitive   = true
}

variable "nb_private_key_file" {
  description = "Path to the Nebius private key file for Terraform provider authentication."
  type        = string
  sensitive   = true
}

###################################
# MK8s Cluster Variables
###################################

variable "project_id" {
  description = "The parent ID for the cluster"
  type        = string
}

variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}

variable "etcd_cluster_size" {
  description = "The size of the etcd cluster"
  type        = number
}

variable "subnet_id" {
  description = "The subnet ID for the cluster"
  type        = string
}

variable "cluster_version" {
  description = "The version of the cluster"
  type        = string
}

variable "enable_public_endpoint" {
  description = "If true, creates a public endpoint for the cluster API. Set to false for private-only access."
  type        = bool
  default     = false
}

variable "enable_audit_logs" {
  description = "When true, pushes Kubernetes audit logs to the Nebius Logs service."
  type        = bool
  default     = true
}

variable "service_cidrs" {
  description = "List of CIDR blocks for Kubernetes Service ClusterIP allocation. Leave null for auto-allocation."
  type        = list(string)
  default     = null
}

variable "labels" {
  description = "Key/value labels attached to the cluster resource."
  type        = map(string)
  default     = {}
}

###################################
# Node Group Variables
###################################

variable "node_service_account_id" {
  description = "Service account ID attached to node instances for registry/API access."
  type        = string
  default     = null
}

###################################
# Kubernetes / Helm Provider
###################################

variable "kubeconfig_path" {
  description = "Path to the kubeconfig file on the VM. Set after running: nebius mk8s cluster get-credentials --id <cluster-id> --internal"
  type        = string
  default     = "~/.kube/config"
}

###################################
# Bastion Host Variables
###################################

variable "tenant_id" {
  description = "Nebius tenant ID — required for the bastion service account IAM group lookup."
  type        = string
}

variable "bastion_platform" {
  description = "Compute platform for the bastion VM: cpu-d3 (AMD Genoa) or cpu-e2 (Intel ICL)."
  type        = string
  default     = "cpu-d3"
}

variable "bastion_preset" {
  description = "vCPU + RAM preset for the bastion VM."
  type        = string
  default     = "4vcpu-16gb"
}

variable "bastion_disk_type" {
  description = <<-EOT
    Storage type for the bastion boot disk.
      - NETWORK_SSD                  (default)
      - NETWORK_HDD
      - NETWORK_SSD_NON_REPLICATED
      - NETWORK_SSD_IO_M3
  EOT
  type        = string
  default     = "NETWORK_SSD"
}

variable "bastion_disk_size_gibibytes" {
  description = "Bastion boot disk size in GiB."
  type        = number
  default     = 64
}

variable "bastion_image_family" {
  description = "Image family for the bastion boot disk. Nebius resolves to the latest image in the family."
  type        = string
  default     = "ubuntu24.04-driverless"
}

variable "bastion_auth_key_expires_at" {
  description = "Absolute expiration timestamp for bastion service-account auth key in RFC3339 format (rotate quarterly by setting next quarter end)."
  type        = string
}

variable "bastion_ssh_user_name" {
  description = "SSH username for the bastion host."
  type        = string
  default     = "bastion"
}

variable "bastion_ssh_public_key" {
  description = <<-EOT
    SSH public key for the bastion. Provide either:
      - key  = "<ssh-rsa ...>"       (inline)
      - path = "~/.ssh/id_rsa.pub"   (file path)
  EOT
  type = object({
    key  = optional(string)
    path = optional(string, "~/.ssh/id_rsa.pub")
  })
  default = {}
}
