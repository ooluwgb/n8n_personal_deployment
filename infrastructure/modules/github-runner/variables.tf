variable "project_id" {
  description = "Nebius project ID that owns the runner resources."
  type        = string
}

variable "tenant_id" {
  description = "Nebius tenant ID used to look up IAM group for runner service account membership."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the runner VM is deployed (must reach private MK8s endpoint)."
  type        = string
}

variable "cluster_id" {
  description = "MK8s cluster ID used to fetch internal kubeconfig on the runner host."
  type        = string
}

variable "instance_name" {
  description = "Runner VM instance name."
  type        = string
  default     = "github-runner"
}

variable "hostname" {
  description = "Optional custom hostname for the runner VM."
  type        = string
  default     = null
}

variable "platform" {
  description = "Compute platform for the runner VM."
  type        = string
  default     = "cpu-d3"
}

variable "preset" {
  description = "Compute preset (vCPU/RAM) for the runner VM."
  type        = string
  default     = "4vcpu-16gb"
}

variable "disk_name" {
  description = "Boot disk name for the runner VM."
  type        = string
  default     = "github-runner-boot-disk"
}

variable "disk_type" {
  description = "Boot disk type for the runner VM."
  type        = string
  default     = "NETWORK_SSD"
}

variable "disk_size_gibibytes" {
  description = "Boot disk size in GiB for the runner VM."
  type        = number
  default     = 64
}

variable "block_size_bytes" {
  description = "Boot disk block size in bytes."
  type        = number
  default     = 4096
}

variable "image_family" {
  description = "Image family for the runner boot disk."
  type        = string
  default     = "ubuntu24.04-driverless"
}

variable "image_family_parent_id" {
  description = "Optional parent ID for custom image family."
  type        = string
  default     = null
}

variable "enable_public_ip" {
  description = "Whether runner NIC should attach a public IP."
  type        = bool
  default     = false
}

variable "security_group_ids" {
  description = "Optional security group IDs for runner NIC."
  type        = list(string)
  default     = []
}

variable "ssh_public_key" {
  description = "Optional SSH public key for break-glass host access."
  type = object({
    key  = optional(string)
    path = optional(string, "~/.ssh/id_rsa.pub")
  })
  default = {}
}

variable "service_account_name" {
  description = "Service account name attached to runner VM."
  type        = string
  default     = "github-runner-sa"
}

variable "service_account_description" {
  description = "Service account description for runner VM."
  type        = string
  default     = "Service account for persistent GitHub self-hosted runner VM."
}

variable "iam_group_name" {
  description = "IAM group name to grant runner service account permissions. Set null to skip group membership."
  type        = string
  default     = "editors"
}

variable "github_runner_url" {
  description = "GitHub repository or organization URL used during runner registration."
  type        = string
}

variable "github_runner_registration_token" {
  description = "Short-lived GitHub runner registration token from Actions runner setup page."
  type        = string
  sensitive   = true
}

variable "github_runner_name" {
  description = "Runner name shown in GitHub. Defaults to instance_name when empty."
  type        = string
  default     = ""
}

variable "github_runner_group" {
  description = "Optional runner group name."
  type        = string
  default     = null
}

variable "github_runner_labels" {
  description = "Runner labels used in workflow runs-on selection."
  type        = list(string)
  default     = ["self-hosted", "linux", "x64", "nebius-private"]
}

variable "github_runner_work_dir" {
  description = "Working directory used by GitHub runner."
  type        = string
  default     = "_work"
}

variable "runner_user" {
  description = "Linux user account that runs the GitHub runner service."
  type        = string
  default     = "github-runner"
}

variable "runner_version" {
  description = "GitHub Actions runner version to install."
  type        = string
  default     = "2.332.0"
}

variable "runner_download_sha256" {
  description = "Optional SHA256 checksum for the downloaded runner archive."
  type        = string
  default     = "f2094522a6b9afeab07ffb586d1eb3f190b6457074282796c497ce7dce9e0f2a"
}

variable "install_nebius_cli" {
  description = "Install Nebius CLI and configure profile from metadata token."
  type        = bool
  default     = true
}

variable "install_kubectl" {
  description = "Install kubectl binary on runner host."
  type        = bool
  default     = true
}

variable "install_helm" {
  description = "Install Helm binary on runner host."
  type        = bool
  default     = true
}

variable "helm_version" {
  description = "Helm release version to install when install_helm=true."
  type        = string
  default     = "v3.17.1"
}

variable "recovery_policy" {
  description = "Runner VM recovery policy (RECOVER or FAIL)."
  type        = string
  default     = "RECOVER"
}

variable "stopped" {
  description = "Whether to keep runner VM stopped."
  type        = bool
  default     = null
}

variable "labels" {
  description = "Resource labels for runner disk, instance, and service account."
  type        = map(string)
  default     = {}
}
