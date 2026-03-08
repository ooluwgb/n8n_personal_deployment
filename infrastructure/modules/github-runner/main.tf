terraform {
  required_providers {
    nebius = {
      source = "terraform-provider.storage.eu-north1.nebius.cloud/nebius/nebius"
    }
  }
}

locals {
  runner_name = trimspace(var.github_runner_name) != "" ? var.github_runner_name : var.instance_name
  runner_labels_csv = join(",", var.github_runner_labels)
  ssh_public_key = var.ssh_public_key.key != null ? var.ssh_public_key.key : (
    fileexists(var.ssh_public_key.path) ? file(var.ssh_public_key.path) : null
  )
}

resource "nebius_iam_v1_service_account" "runner" {
  parent_id   = var.project_id
  name        = var.service_account_name
  description = var.service_account_description
  labels      = var.labels
}

data "nebius_iam_v1_group" "runner_group" {
  count = var.iam_group_name == null ? 0 : 1

  name      = var.iam_group_name
  parent_id = var.tenant_id
}

resource "nebius_iam_v1_group_membership" "runner" {
  count = var.iam_group_name == null ? 0 : 1

  parent_id = data.nebius_iam_v1_group.runner_group[0].id
  member_id = nebius_iam_v1_service_account.runner.id
}

resource "nebius_compute_v1_disk" "runner_boot" {
  parent_id = var.project_id
  name      = var.disk_name
  labels    = var.labels
  type      = var.disk_type

  size_gibibytes   = var.disk_size_gibibytes
  block_size_bytes = var.block_size_bytes

  source_image_family = {
    image_family = var.image_family
    parent_id    = var.image_family_parent_id
  }
}

resource "nebius_compute_v1_instance" "runner" {
  parent_id = var.project_id
  name      = var.instance_name
  hostname  = var.hostname
  labels = merge(var.labels, {
    component = "github-runner"
  })

  lifecycle {
    # Registration token is short-lived and embedded in initial bootstrap cloud-init.
    # Ignore later cloud-init diffs so plans stay stable after runner is registered.
    ignore_changes = [cloud_init_user_data]
  }

  boot_disk = {
    attach_mode   = "READ_WRITE"
    existing_disk = {
      id = nebius_compute_v1_disk.runner_boot.id
    }
  }

  network_interfaces = [
    {
      name      = "eth0"
      subnet_id = var.subnet_id

      ip_address = {}

      public_ip_address = var.enable_public_ip ? {} : null

      security_groups = length(var.security_group_ids) > 0 ? [
        for sg_id in var.security_group_ids : { id = sg_id }
      ] : null
    }
  ]

  resources = {
    platform = var.platform
    preset   = var.preset
  }

  service_account_id = nebius_iam_v1_service_account.runner.id
  recovery_policy    = var.recovery_policy
  stopped            = var.stopped

  cloud_init_user_data = templatefile(
    "${path.module}/templates/github-runner-cloud-init.tftpl",
    {
      runner_user                      = var.runner_user
      runner_version                   = var.runner_version
      runner_download_sha256           = var.runner_download_sha256
      github_runner_url                = var.github_runner_url
      github_runner_registration_token = var.github_runner_registration_token
      github_runner_name               = local.runner_name
      github_runner_labels             = local.runner_labels_csv
      github_runner_group              = var.github_runner_group
      github_runner_work_dir           = var.github_runner_work_dir
      ssh_public_key                   = local.ssh_public_key
      project_id                       = var.project_id
      cluster_id                       = var.cluster_id
      install_nebius_cli               = var.install_nebius_cli
      install_kubectl                  = var.install_kubectl
      install_helm                     = var.install_helm
      helm_version                     = var.helm_version
    }
  )
}
