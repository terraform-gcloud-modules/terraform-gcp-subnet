provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
}

module "vpc" {
  source  = "clouddrove/vpc/gcp"
  version = "1.0.0"

  name                           = "vpc"
  environment                    = "test"
  label_order                    = ["environment", "name"]
  google_compute_network_enabled = true
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

  firewall_rules = [
    {
      name          = "allow-internal"
      description   = "Allow internal traffic"
      direction     = "INGRESS"
      priority      = 1000
      source_ranges = ["10.10.0.0/16"]
      target_tags   = []
      allow = [
        { protocol = "tcp", ports = ["443", "8080"] },
        { protocol = "icmp", ports = [] }
      ]
      deny = []
    }
  ]

  routes = [
    {
      name             = "internet"
      description      = "Default internet route"
      dest_range       = "0.0.0.0/0"
      next_hop_gateway = "default-internet-gateway"
      priority         = 1000
      tags             = []
    }
  ]

  google_compute_router_enabled = true
  asn                           = 64514

  google_compute_nat_enabled = true
  nats = [
    {
      name                               = "main-nat"
      region                             = "asia-south1"
      nat_ip_allocate_option             = "AUTO_ONLY"
      source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
      nat_log_enable                     = false
      filter                             = "ERRORS_ONLY"
      reserve_static_ip                  = false
    }
  ]
}