# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# ------------------------------------------------------------------------------
# Resources
# ------------------------------------------------------------------------------

locals {
  name        = "subnet"
  environment = var.environment
  label_order = var.label_order
}
module "vpc" {
  source = "git::https://github.com/terraform-gcloud-modules/terraform-gcp-vpc.git?ref=v0.0.1"

  name        = "vpc"
  environment = var.environment
  label_order = ["name", "environment"]
  project_id  = var.gcp_project_id
}

module "subnet" {
  source = "../../"

  name        = local.name
  environment = local.environment
  label_order = local.label_order

  project_id = var.gcp_project_id
  network    = module.vpc.vpc_id
  gcp_region = "us-central1"


  subnets = [
    {
      name                     = "web"
      ip_cidr_range            = "10.10.0.0/24"
      region                   = "us-central1"
      description              = "Public-facing web tier subnet"
      private_ip_google_access = true
      stack_type               = "IPV4_ONLY"
      secondary_ip_ranges      = []
      log_config = {
        aggregation_interval = "INTERVAL_5_SEC"
        flow_sampling        = 0.5
        metadata             = "INCLUDE_ALL_METADATA"
        filter_expr          = "true"
      }
    },
    {
      name                     = "app"
      ip_cidr_range            = "10.20.0.0/24"
      region                   = "us-central1"
      description              = "Application tier subnet"
      private_ip_google_access = false
      stack_type               = "IPV4_ONLY"
      secondary_ip_ranges      = []
      log_config = {
        aggregation_interval = "INTERVAL_5_SEC"
        flow_sampling        = 0.5
        metadata             = "INCLUDE_ALL_METADATA"
        filter_expr          = "false" # flow logs off for app subnet
      }
    },
  ]
}