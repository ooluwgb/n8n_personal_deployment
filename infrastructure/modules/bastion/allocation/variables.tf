###################################
# Required variables
###################################

variable "project_id" {
  description = "Nebius project ID that owns the IP allocations."
  type        = string
}

variable "subnet_id" {
  description = "VPC subnet ID for the private IP allocation. Must match the subnet used by the bastion instance."
  type        = string
}

###################################
# Naming
###################################

variable "public_ip_name" {
  description = "Human-readable name for the public IP allocation."
  type        = string
  default     = "bastion-public-ip"
}

variable "private_ip_name" {
  description = "Human-readable name for the private IP allocation."
  type        = string
  default     = "bastion-private-ip"
}

###################################
# Labels
###################################

variable "labels" {
  description = "Key/value labels applied to both allocations."
  type        = map(string)
  default     = {}
}
