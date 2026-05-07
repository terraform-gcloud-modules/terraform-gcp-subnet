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

  # ── 3 FIREWALL RULES — each fully independent ─────────────────
  firewall_rules = [
    {
      name          = "allow-https-web"
      description   = "Allow HTTPS to web-server tagged VMs from internet"
      direction     = "INGRESS"
      priority      = 1000
      source_ranges = ["0.0.0.0/0"]
      target_tags   = ["web-server"]
      allow = [
        { protocol = "tcp", ports = ["443", "80"] }
      ]
      deny = []
    },
    {
      name          = "allow-internal"
      description   = "Allow all internal VPC traffic"
      direction     = "INGRESS"
      priority      = 1000
      source_ranges = ["10.0.0.0/8"]
      target_tags   = []
      allow = [
        { protocol = "tcp", ports = ["0-65535"] },
        { protocol = "udp", ports = ["0-65535"] },
        { protocol = "icmp", ports = [] }
      ]
      deny = []
    },
    {
      name               = "deny-egress-internet"
      description        = "Block all outbound internet traffic except via NAT"
      direction          = "EGRESS"
      priority           = 65534
      destination_ranges = ["0.0.0.0/0"]
      source_ranges      = []
      target_tags        = ["no-external-ip"]
      allow              = []
      deny = [
        { protocol = "all", ports = [] }
      ]
    }
  ]

  # ── 2 ROUTES ──────────────────────────────────────────────────
  routes = [
    {
      name             = "internet"
      description      = "Default route to internet gateway"
      dest_range       = "0.0.0.0/0"
      next_hop_gateway = "default-internet-gateway"
      priority         = 1000
      tags             = []
    },
    {
      name             = "restricted-google-apis"
      description      = "Route to restricted Google APIs range"
      dest_range       = "199.36.153.4/30"
      next_hop_gateway = "default-internet-gateway"
      priority         = 1000
      tags             = []
    }
  ]

  # ── ROUTER ────────────────────────────────────────────────────
  google_compute_router_enabled = true
  router_description            = "Shared Cloud Router for app environment"
  asn                           = 64514

  # ── 2 NAT CONFIGS ────────────────────────────────────────────
  google_compute_nat_enabled = true
  nats = [
    {
      name                               = "us-central1-nat"
      region                             = "us-central1"
      nat_ip_allocate_option             = "AUTO_ONLY"
      source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
      nat_log_enable                     = true
      filter                             = "ERRORS_ONLY"
      reserve_static_ip                  = false
    },
    {
      name                               = "us-east1-nat"
      region                             = "us-east1"
      nat_ip_allocate_option             = "MANUAL_ONLY"
      source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
      nat_log_enable                     = true
      filter                             = "ERRORS_ONLY"
      reserve_static_ip                  = true # reserves a static IP for this NAT
    }
  ]
}