###################################
# Required variables
###################################

variable "project_id" {
  description = "Nebius project ID that owns the service account."
  type        = string
}

variable "tenant_id" {
  description = "Nebius tenant ID — needed to look up the IAM group (e.g. editors)."
  type        = string
}

###################################
# Service account identity
###################################

variable "service_account_name" {
  description = "Human-readable name for the bastion service account."
  type        = string
  default     = "bastion-sa"
}

variable "service_account_description" {
  description = "Description for the bastion service account."
  type        = string
  default     = "Service account for the bastion host — used by Nebius CLI and kubectl."
}

###################################
# Auth key configuration
###################################

variable "key_expiry" {
  description = "Duration until the auth public key expires (Go duration format). Default: 1 year."
  type        = string
  default     = "8760h"
}

###################################
# IAM group
###################################

variable "iam_group_name" {
  description = "Name of the IAM group to add the service account to. Default: editors."
  type        = string
  default     = "editors"
}

###################################
# Labels
###################################

variable "labels" {
  description = "Key/value labels applied to the service account."
  type        = map(string)
  default     = {}
}
