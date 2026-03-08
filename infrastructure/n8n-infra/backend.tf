terraform {
  backend "s3" {
    bucket = "nebius-infrastructure-ayodele-dev"
    key    = "n8n_infra.tfstate"

    endpoints = {
      s3 = "https://storage.eu-north1.nebius.cloud:443"
    }
    region = "eu-north1"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}