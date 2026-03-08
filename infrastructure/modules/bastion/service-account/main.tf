terraform {
  required_providers {
    nebius = {
      source = "terraform-provider.storage.eu-north1.nebius.cloud/nebius/nebius"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
}

###################################
# Bastion — Service Account
###################################
# Creates a service account for the bastion VM so that
# the Nebius CLI and kubectl can authenticate automatically
# via the instance metadata token at /mnt/cloud-metadata/token.
###################################
# TLS Key Pair
###################################

resource "tls_private_key" "bastion_sa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

###################################
# Service Account
###################################

resource "nebius_iam_v1_service_account" "this" {
  parent_id   = var.project_id
  name        = var.service_account_name
  description = var.service_account_description
  labels      = var.labels
}

###################################
# Auth Public Key
###################################

resource "nebius_iam_v1_auth_public_key" "this" {
  parent_id  = var.project_id
  name       = "${var.service_account_name}-auth-key"
  expires_at = timeadd(timestamp(), var.key_expiry)

  account = {
    service_account = {
      id = nebius_iam_v1_service_account.this.id
    }
  }

  data = tls_private_key.bastion_sa_key.public_key_pem
}

###################################
# Group Membership (editors)
###################################

data "nebius_iam_v1_group" "editors" {
  name      = var.iam_group_name
  parent_id = var.tenant_id
}

resource "nebius_iam_v1_group_membership" "this" {
  parent_id = data.nebius_iam_v1_group.editors.id
  member_id = nebius_iam_v1_service_account.this.id
}
