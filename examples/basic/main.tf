provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
}

locals {
  name        = "basic"
  environment = var.environment
  label_order = var.label_order
}

module "vpc" {
source = "git::https://github.com/terraform-gcloud-modules/terraform-gcp-vpc.git?ref=v0.0.1"

  name        = var.name
  environment = var.environment
  label_order = ["name", "environment"]
  project_id  = var.project_id
}

module "subnet" {
  source = "../../"

  name        = "basic"
  environment = var.environment
  label_order = var.label_order
  project_id  = var.gcp_project_id
  network     = module.vpc.vpc_id
  gcp_region  = var.gcp_region

  subnets = [
    {
      name                     = "main"
      ip_cidr_range            = "10.10.0.0/24"
      region                   = "asia-south1"
      description              = "Basic example subnet"
      private_ip_google_access = true
      stack_type               = "IPV4_ONLY"
      secondary_ip_ranges      = []
      log_config               = null
    }
  ]
}