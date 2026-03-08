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