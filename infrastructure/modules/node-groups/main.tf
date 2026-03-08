terraform {
  required_providers {
    nebius = {
      source = "terraform-provider.storage.eu-north1.nebius.cloud/nebius/nebius"
    }
  }
}

###################################
# Parse YAML + apply defaults
###################################
locals {
  raw = yamldecode(file(var.config_file))
  valid_types = toset(["application", "database"])
  _has_fixed = {
    for key, ng in local.raw.node_groups : key => try(ng.fixed_node_count, null) != null
  }
  _has_autoscaling = {
    for key, ng in local.raw.node_groups : key =>
      try(ng.autoscaling_min, null) != null || try(ng.autoscaling_max, null) != null
  }

  node_groups = {
    for key, ng in local.raw.node_groups : key => {
      name            = ng.name
      node_group_type = ng.node_group_type
      platform = try(ng.platform, "cpu-d3")
      preset   = try(ng.preset, "4vcpu-16gb")
      use_fixed        = local._has_fixed[key]
      fixed_node_count = try(ng.fixed_node_count, null)
      autoscaling_min  = try(ng.autoscaling_min, 2)
      autoscaling_max  = try(ng.autoscaling_max, 3)

      # Boot disk (NETWORK_SSD_IO_M3 requires sizes in multiples of 93 GiB)
      boot_disk_size_gb = try(ng.boot_disk_size_gb, ng.node_group_type == "database" ? 93 : 96)
      boot_disk_type    = try(ng.boot_disk_type, ng.node_group_type == "database" ? "NETWORK_SSD_IO_M3" : "NETWORK_SSD")

      # Networking
      subnet_id        = try(ng.subnet_id, null)
      enable_public_ip = try(ng.enable_public_ip, false)

      # Kubernetes metadata
      node_labels = try(ng.node_labels, {})
      node_taints = try(ng.node_taints, [])

      # Resource labels
      resource_labels = try(ng.resource_labels, {})

      # Cost optimisation
      preemptible = try(ng.preemptible, false)

      # Shared filesystems
      filesystem_id        = try(ng.filesystem_id, null)
      filesystem_mount_tag = try(ng.filesystem_mount_tag, "data")

      # GPU
      gpu_cluster_id     = try(ng.gpu_cluster_id, null)
      gpu_drivers_preset = try(ng.gpu_drivers_preset, null)

      # OS
      os = try(ng.os, "ubuntu24.04")

      # Per-group service account override
      service_account_id = try(ng.service_account_id, null)

      # Per-group cloud-init
      cloud_init_user_data = try(ng.cloud_init_user_data, null)

      # Rolling-update strategy
      drain_timeout         = try(ng.drain_timeout, null)
      max_surge_count       = try(ng.max_surge_count, null)
      max_unavailable_count = try(ng.max_unavailable_count, null)

      # Auto repair
      enable_auto_repair  = try(ng.enable_auto_repair, true)
      auto_repair_timeout = try(ng.auto_repair_timeout, "5m")
    }
  }
}

###################################
# Input validation
###################################
resource "terraform_data" "validate_node_groups" {
  for_each = local.node_groups

  lifecycle {
    precondition {
      condition     = contains(local.valid_types, each.value.node_group_type)
      error_message = "Node group \"${each.key}\": node_group_type must be \"application\" or \"database\", got \"${each.value.node_group_type}\"."
    }
    precondition {
      condition     = !(local._has_fixed[each.key] && local._has_autoscaling[each.key])
      error_message = "Node group \"${each.key}\": cannot set both fixed_node_count and autoscaling_min/max — they are mutually exclusive."
    }
    precondition {
      condition = (
        !local._has_autoscaling[each.key] ||
        (try(local.raw.node_groups[each.key].autoscaling_min, null) != null &&
         try(local.raw.node_groups[each.key].autoscaling_max, null) != null)
      )
      error_message = "Node group \"${each.key}\": when using autoscaling, both autoscaling_min and autoscaling_max must be specified."
    }
  }
}

###################################
# Node Group Resource
###################################
resource "nebius_mk8s_v1_node_group" "this" {
  for_each = local.node_groups

  depends_on = [terraform_data.validate_node_groups]

  parent_id = var.cluster_id
  name      = each.value.name
  version   = var.k8s_version
  labels = merge(each.value.resource_labels, {
    node_group_type = each.value.node_group_type
  })
  fixed_node_count = each.value.use_fixed ? each.value.fixed_node_count : null

  autoscaling = !each.value.use_fixed ? {
    min_node_count = each.value.autoscaling_min
    max_node_count = each.value.autoscaling_max
  } : null


  template = {
    resources = {
      platform = each.value.platform
      preset   = each.value.preset
    }
    boot_disk = {
      size_gibibytes = each.value.boot_disk_size_gb
      type           = each.value.boot_disk_type
    }
    network_interfaces = [
      {
        subnet_id         = each.value.subnet_id != null ? each.value.subnet_id : var.subnet_id
        public_ip_address = each.value.enable_public_ip ? {} : null
      }
    ]
    metadata = {
      labels = merge(each.value.node_labels, {
        node_group_type = each.value.node_group_type
      })
    }
    taints = length(each.value.node_taints) > 0 ? [
      for t in each.value.node_taints : {
        key    = t.key
        value  = t.value
        effect = t.effect
      }
    ] : null
    service_account_id = each.value.service_account_id != null ? each.value.service_account_id : var.service_account_id
    preemptible = each.value.preemptible ? {} : null
    filesystems = each.value.filesystem_id != null ? [
      {
        attach_mode         = "READ_WRITE"
        mount_tag           = each.value.filesystem_mount_tag
        existing_filesystem = { id = each.value.filesystem_id }
      }
    ] : null
    gpu_cluster = each.value.gpu_cluster_id != null ? {
      id = each.value.gpu_cluster_id
    } : null
    gpu_settings = each.value.gpu_drivers_preset != null ? {
      drivers_preset = each.value.gpu_drivers_preset
    } : null
    os = each.value.os
    cloud_init_user_data = each.value.cloud_init_user_data
  }
  strategy = (
    each.value.max_surge_count != null ||
    each.value.max_unavailable_count != null ||
    each.value.drain_timeout != null
  ) ? {
    drain_timeout = each.value.drain_timeout

    max_surge = each.value.max_surge_count != null ? {
      count = each.value.max_surge_count
    } : null

    max_unavailable = each.value.max_unavailable_count != null ? {
      count = each.value.max_unavailable_count
    } : null
  } : null
  auto_repair = each.value.enable_auto_repair ? {
    conditions = [
      {
        type    = "Ready"
        status  = "FALSE"
        timeout = each.value.auto_repair_timeout
      }
    ]
  } : null
}
