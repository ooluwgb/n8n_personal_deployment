project_id             = "project-e00c4897pr00mbtx4cyc6b"
cluster_name           = "n8n-terraform-deployed-cluster"
etcd_cluster_size      = 3
subnet_id              = "vpcsubnet-e00bhb8yqj7vz1h6ca"
cluster_version        = "1.32"
enable_public_endpoint = false
enable_audit_logs      = true

###################################
# Bastion Host
###################################
tenant_id                  = "tenant-e00vp7pfdrsjyw9k18"                 # TODO: set your tenant ID
bastion_platform           = "cpu-d3"
bastion_preset             = "4vcpu-16gb"
bastion_disk_type          = "NETWORK_SSD"
bastion_disk_size_gibibytes = 64
bastion_image_family        = "ubuntu24.04-driverless"
bastion_auth_key_expires_at = "2026-06-30T23:59:59Z"
bastion_ssh_user_name      = "bastion"
# bastion_ssh_public_key   = { path = "~/.ssh/id_rsa.pub" }  # default — reads from your machine