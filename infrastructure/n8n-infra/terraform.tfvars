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

###################################
# GitHub Self-Hosted Runner (persistent)
###################################
# Enabled by default. Set to false only when you intentionally want to skip runner provisioning.
enable_github_runner = true

# github_runner_url = "https://github.com/ooluwgb/n8n_personal_deployment"  # optional in CI; defaults to current repo
# github_runner_registration_token is generated automatically in CI when runner provisioning is enabled.
# github_runner_name = "n8n-private-runner-01"
# github_runner_group = "Default"
# github_runner_labels = ["self-hosted", "linux", "x64", "nebius-private"]
# github_runner_instance_name = "github-runner"
# github_runner_subnet_id = "vpcsubnet-xxxxxxxxxxxxxxxx"
# github_runner_ssh_public_key = { path = "~/.ssh/id_rsa.pub" }