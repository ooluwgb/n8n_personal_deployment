###################################
# Service account identity
###################################

output "service_account_id" {
  description = "The unique ID of the bastion service account."
  value       = nebius_iam_v1_service_account.this.id
}

output "service_account_name" {
  description = "The human-readable name of the service account."
  value       = nebius_iam_v1_service_account.this.name
}

output "service_account_active" {
  description = "Whether the service account is active."
  value       = try(nebius_iam_v1_service_account.this.status.active, null)
}

###################################
# Auth key
###################################

output "auth_public_key_id" {
  description = "The unique ID of the auth public key."
  value       = nebius_iam_v1_auth_public_key.this.id
}

output "auth_public_key_fingerprint" {
  description = "Fingerprint of the uploaded public key."
  value       = try(nebius_iam_v1_auth_public_key.this.status.fingerprint, null)
}

output "auth_public_key_state" {
  description = "State of the auth key (ACTIVE, INACTIVE, EXPIRED, DELETING, DELETED)."
  value       = try(nebius_iam_v1_auth_public_key.this.status.state, null)
}

###################################
# Group membership
###################################

output "group_membership_id" {
  description = "The unique ID of the group membership resource."
  value       = nebius_iam_v1_group_membership.this.id
}

output "iam_group_id" {
  description = "The ID of the IAM group the service account was added to."
  value       = data.nebius_iam_v1_group.editors.id
}
