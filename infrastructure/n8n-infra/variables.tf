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

###################################
# GitHub Self-Hosted Runner
###################################

variable "enable_github_runner" {
  description = "When true, provisions a persistent GitHub self-hosted runner VM in Nebius."
  type        = bool
  default     = true
}

variable "github_runner_url" {
  description = "GitHub repository or organization URL (for example, https://github.com/ooluwgb/n8n_personal_deployment)."
  type        = string
  default     = null

  validation {
    condition     = !var.enable_github_runner || (var.github_runner_url != null && trimspace(var.github_runner_url) != "")
    error_message = "Set github_runner_url when enable_github_runner=true."
  }
}

variable "github_runner_registration_token" {
  description = "Short-lived GitHub runner registration token from Actions -> Runners page."
  type        = string
  default     = null
  sensitive   = true

  validation {
    condition     = !var.enable_github_runner || (var.github_runner_registration_token != null && trimspace(var.github_runner_registration_token) != "")
    error_message = "Set github_runner_registration_token when enable_github_runner=true."
  }
}

variable "github_runner_subnet_id" {
  description = "Optional override subnet ID for runner VM. Null defaults to subnet_id."
  type        = string
  default     = null
}

variable "github_runner_instance_name" {
  description = "Runner VM instance name."
  type        = string
  default     = "github-runner"
}

variable "github_runner_hostname" {
  description = "Optional custom hostname for runner VM."
  type        = string
  default     = null
}

variable "github_runner_platform" {
  description = "Compute platform for runner VM."
  type        = string
  default     = "cpu-d3"
}

variable "github_runner_preset" {
  description = "Compute preset for runner VM."
  type        = string
  default     = "4vcpu-16gb"
}

variable "github_runner_disk_name" {
  description = "Boot disk name for runner VM."
  type        = string
  default     = "github-runner-boot-disk"
}

variable "github_runner_disk_type" {
  description = "Boot disk type for runner VM."
  type        = string
  default     = "NETWORK_SSD"
}

variable "github_runner_disk_size_gibibytes" {
  description = "Boot disk size in GiB for runner VM."
  type        = number
  default     = 64
}

variable "github_runner_block_size_bytes" {
  description = "Boot disk block size in bytes."
  type        = number
  default     = 4096
}

variable "github_runner_image_family" {
  description = "Image family used for runner VM boot disk."
  type        = string
  default     = "ubuntu24.04-driverless"
}

variable "github_runner_image_family_parent_id" {
  description = "Optional parent ID for custom runner image family."
  type        = string
  default     = null
}

variable "github_runner_enable_public_ip" {
  description = "When true, attaches public IP to runner VM NIC."
  type        = bool
  default     = false
}

variable "github_runner_security_group_ids" {
  description = "Optional security groups for runner VM NIC."
  type        = list(string)
  default     = []
}

variable "github_runner_ssh_public_key" {
  description = "Optional SSH key for break-glass access to runner VM."
  type = object({
    key  = optional(string)
    path = optional(string, "~/.ssh/id_rsa.pub")
  })
  default = {}
}

variable "github_runner_service_account_name" {
  description = "Service account name for runner VM."
  type        = string
  default     = "github-runner-sa"
}

variable "github_runner_service_account_description" {
  description = "Service account description for runner VM."
  type        = string
  default     = "Service account for persistent GitHub self-hosted runner VM."
}

variable "github_runner_iam_group_name" {
  description = "IAM group to add runner service account to. Set null to skip group membership."
  type        = string
  default     = "editors"
}

variable "github_runner_name" {
  description = "Runner name registered in GitHub. Empty string falls back to github_runner_instance_name."
  type        = string
  default     = ""
}

variable "github_runner_group" {
  description = "Optional GitHub runner group name."
  type        = string
  default     = null
}

variable "github_runner_labels" {
  description = "Runner labels used in workflow runs-on selectors."
  type        = list(string)
  default     = ["self-hosted", "linux", "x64", "nebius-private"]
}

variable "github_runner_work_dir" {
  description = "GitHub runner work directory path."
  type        = string
  default     = "_work"
}

variable "github_runner_user" {
  description = "Linux user account used for GitHub runner service."
  type        = string
  default     = "github-runner"
}

variable "github_runner_version" {
  description = "GitHub Actions runner version to install."
  type        = string
  default     = "2.332.0"
}

variable "github_runner_download_sha256" {
  description = "SHA256 checksum for selected runner archive."
  type        = string
  default     = "f2094522a6b9afeab07ffb586d1eb3f190b6457074282796c497ce7dce9e0f2a"
}

variable "github_runner_install_nebius_cli" {
  description = "Install Nebius CLI and configure profile using instance metadata token."
  type        = bool
  default     = true
}

variable "github_runner_install_kubectl" {
  description = "Install kubectl on runner VM."
  type        = bool
  default     = true
}

variable "github_runner_install_helm" {
  description = "Install Helm on runner VM."
  type        = bool
  default     = true
}

variable "github_runner_helm_version" {
  description = "Helm version installed on runner VM when github_runner_install_helm=true."
  type        = string
  default     = "v3.17.1"
}

variable "github_runner_recovery_policy" {
  description = "Recovery policy for runner VM (RECOVER or FAIL)."
  type        = string
  default     = "RECOVER"
}

variable "github_runner_stopped" {
  description = "Whether runner VM should be kept in stopped state."
  type        = bool
  default     = null
}

variable "github_runner_resource_labels" {
  description = "Resource labels applied to runner VM, boot disk, and service account."
  type        = map(string)
  default     = {}
}
