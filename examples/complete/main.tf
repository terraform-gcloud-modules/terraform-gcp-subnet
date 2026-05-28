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

  name        = "app"
  environment = var.environment
  label_order = var.label_order
  project_id  = var.gcp_project_id
  network     = module.vpc.vpc_id
  gcp_region  = var.gcp_region

  # ── 3 SUBNETS created in one go ──────────────────────────────
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
      private_ip_google_access = true
      stack_type               = "IPV4_ONLY"
      # GKE secondary ranges on this subnet
      secondary_ip_ranges = [
        { range_name = "pods", ip_cidr_range = "10.3.0.0/16" },
        { range_name = "services", ip_cidr_range = "10.1.0.0/16" }
      ]
      log_config = {
        aggregation_interval = "INTERVAL_5_SEC"
        flow_sampling        = 0.5
        metadata             = "INCLUDE_ALL_METADATA"
        filter_expr          = "true"
      }
    },
    {
      name                     = "db"
      ip_cidr_range            = "10.30.0.0/24"
      region                   = "us-east1"
      description              = "Database tier subnet — no flow logs"
      private_ip_google_access = true
      stack_type               = "IPV4_ONLY"
      secondary_ip_ranges      = []
      log_config               = null # flow logs off for db subnet
    }
  ]
}