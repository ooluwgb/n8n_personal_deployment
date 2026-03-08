module "cluster" {
  source                 = "../modules/mk8s-cluster"
  cluster_name           = var.cluster_name
  project_id             = var.project_id
  etcd_cluster_size      = var.etcd_cluster_size
  subnet_id              = var.subnet_id
  cluster_version        = var.cluster_version
  enable_public_endpoint = var.enable_public_endpoint
  enable_audit_logs      = var.enable_audit_logs
  service_cidrs          = var.service_cidrs
  labels                 = var.labels
}


module "node_group" {
  source      = "../modules/node-groups"
  cluster_id  = module.cluster.cluster_id
  k8s_version = var.cluster_version
  subnet_id   = var.subnet_id
  config_file = "${path.module}/node-groups.yaml"

  service_account_id = var.node_service_account_id
}


###################################
# Bastion Host
###################################

module "bastion" {
  source = "../modules/bastion"
  project_id = var.project_id
  tenant_id  = var.tenant_id
  subnet_id  = var.subnet_id
  cluster_id = module.cluster.cluster_id
  platform = var.bastion_platform
  preset   = var.bastion_preset
  disk_type           = var.bastion_disk_type
  disk_size_gibibytes = var.bastion_disk_size_gibibytes
  image_family        = var.bastion_image_family
  auth_key_expires_at = var.bastion_auth_key_expires_at
  ssh_user_name  = var.bastion_ssh_user_name
  ssh_public_key = var.bastion_ssh_public_key
  labels = var.labels
}

###################################
# GitHub Self-Hosted Runner
###################################

module "github_runner" {
  count  = var.enable_github_runner ? 1 : 0
  source = "../modules/github-runner"

  project_id = var.project_id
  tenant_id  = var.tenant_id
  subnet_id  = var.github_runner_subnet_id != null ? var.github_runner_subnet_id : var.subnet_id
  cluster_id = module.cluster.cluster_id

  github_runner_url                = var.github_runner_url
  github_runner_registration_token = var.github_runner_registration_token

  instance_name      = var.github_runner_instance_name
  hostname           = var.github_runner_hostname
  enable_public_ip   = var.github_runner_enable_public_ip
  security_group_ids = var.github_runner_security_group_ids
  ssh_public_key     = var.github_runner_ssh_public_key

  platform             = var.github_runner_platform
  preset               = var.github_runner_preset
  disk_name            = var.github_runner_disk_name
  disk_type            = var.github_runner_disk_type
  disk_size_gibibytes  = var.github_runner_disk_size_gibibytes
  block_size_bytes     = var.github_runner_block_size_bytes
  image_family         = var.github_runner_image_family
  image_family_parent_id = var.github_runner_image_family_parent_id

  service_account_name        = var.github_runner_service_account_name
  service_account_description = var.github_runner_service_account_description
  iam_group_name              = var.github_runner_iam_group_name

  github_runner_name     = var.github_runner_name
  github_runner_group    = var.github_runner_group
  github_runner_labels   = var.github_runner_labels
  github_runner_work_dir = var.github_runner_work_dir

  runner_user            = var.github_runner_user
  runner_version         = var.github_runner_version
  runner_download_sha256 = var.github_runner_download_sha256

  install_nebius_cli = var.github_runner_install_nebius_cli
  install_kubectl    = var.github_runner_install_kubectl
  install_helm       = var.github_runner_install_helm
  helm_version       = var.github_runner_helm_version

  recovery_policy = var.github_runner_recovery_policy
  stopped         = var.github_runner_stopped
  labels          = var.github_runner_resource_labels
}