module "labels" {
  source  = "clouddrove/labels/gcp"
  version = "1.0.0"

  name        = var.name
  environment = var.environment
  label_order = var.label_order
}

resource "google_compute_subnetwork" "subnetwork" {
  for_each = var.google_compute_subnetwork_enabled && var.module_enabled ? {
    for s in var.subnets : s.name => s
  } : {}

  name    = "${module.labels.id}-${each.key}"
  project = var.project_id
  network = var.network


  region = try(
    coalesce(each.value.region, var.gcp_region),
    var.gcp_region
  )

  ip_cidr_range = each.value.ip_cidr_range

  description              = try(each.value.description, "")
  private_ip_google_access = try(each.value.private_ip_google_access, true)

  purpose = try(each.value.purpose, null)
  role    = try(each.value.role, null)

  stack_type                 = try(each.value.stack_type, "IPV4_ONLY")
  ipv6_access_type           = try(each.value.ipv6_access_type, null)
  private_ipv6_google_access = try(each.value.private_ipv6_google_access, null)

  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ip_ranges != null ? each.value.secondary_ip_ranges : []

    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }


  dynamic "log_config" {
    for_each = try(each.value.log_config, null) != null ? [each.value.log_config] : []

    content {
      aggregation_interval = try(log_config.value.aggregation_interval, "INTERVAL_5_SEC")
      flow_sampling        = try(log_config.value.flow_sampling, 0.5)
      metadata             = try(log_config.value.metadata, "INCLUDE_ALL_METADATA")
      metadata_fields      = try(log_config.value.metadata, "INCLUDE_ALL_METADATA") == "CUSTOM_METADATA" ? try(log_config.value.metadata_fields, null) : null

      filter_expr = try(log_config.value.filter_expr, "true")
    }
  }

  dynamic "timeouts" {
    for_each = try([var.module_timeouts.google_compute_subnetwork], [])

    content {
      create = try(timeouts.value.create, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}


resource "google_compute_firewall" "rules" {
  for_each = var.google_compute_firewall_enabled && var.module_enabled ? {
    for r in var.firewall_rules : r.name => r
  } : {}

  name        = "${module.labels.id}-${each.key}"
  description = try(each.value.description, "")
  network     = var.network
  direction   = try(each.value.direction, "INGRESS")
  priority    = try(each.value.priority, 1000)
  disabled    = try(each.value.disabled, false)

  source_ranges = (
    try(each.value.direction, "INGRESS") == "INGRESS" &&
    length(try(each.value.source_ranges, [])) > 0
  ) ? each.value.source_ranges : null

  destination_ranges = (
    try(each.value.direction, "INGRESS") == "EGRESS" &&
    length(try(each.value.destination_ranges, [])) > 0
  ) ? each.value.destination_ranges : null

  target_tags = length(try(each.value.target_tags, [])) > 0 ? each.value.target_tags : null
  source_tags = length(try(each.value.source_tags, [])) > 0 ? each.value.source_tags : null

  dynamic "allow" {
    for_each = try(each.value.allow, [])

    content {
      protocol = allow.value.protocol
      ports    = try(allow.value.ports, [])
    }
  }

  dynamic "deny" {
    for_each = try(each.value.deny, [])

    content {
      protocol = deny.value.protocol
      ports    = try(deny.value.ports, [])
    }
  }
}


resource "google_compute_route" "routes" {
  for_each = var.google_compute_route_enabled && var.module_enabled ? {
    for r in var.routes : r.name => r
  } : {}

  name        = "${module.labels.id}-${each.key}"
  description = try(each.value.description, "")
  dest_range  = try(each.value.dest_range, "0.0.0.0/0")
  network     = var.network
  priority    = try(each.value.priority, 1000)


  next_hop_gateway = try(each.value.next_hop_ip, null) == null ? try(each.value.next_hop_gateway, "default-internet-gateway") : null
  next_hop_ip      = try(each.value.next_hop_ip, null)

  tags = length(try(each.value.tags, [])) > 0 ? each.value.tags : null
}


# Only created when at least one NAT is requested
resource "google_compute_router" "router" {
  count = (
    var.google_compute_router_enabled &&
    var.module_enabled &&
    length(var.nats) > 0
  ) ? 1 : 0

  name        = "${module.labels.id}-router"
  description = var.router_description
  region      = var.gcp_region
  network     = var.network

  bgp {
    asn = var.asn
  }
}

# STATIC IP ADDRESSES — only for NATs with reserve_static_ip = true

resource "google_compute_address" "nat_ips" {
  for_each = var.module_enabled ? {
    for n in var.nats : n.name => n if try(n.reserve_static_ip, false)
  } : {}

  name = "${module.labels.id}-${each.key}-ip"


  region = try(
    coalesce(try(each.value.region, ""), var.gcp_region),
    var.gcp_region
  )
}

# CLOUD NAT — for_each creates one NAT per entry in var.nats
# Attaches to the shared Cloud Router above
resource "google_compute_router_nat" "nats" {
  for_each = var.google_compute_nat_enabled && var.module_enabled ? {
    for n in var.nats : n.name => n
  } : {}

  name   = "${module.labels.id}-${each.key}"
  router = google_compute_router.router[0].name

  region = try(
    coalesce(try(each.value.region, ""), var.gcp_region),
    var.gcp_region
  )

  nat_ip_allocate_option = try(each.value.reserve_static_ip, false) ? "MANUAL_ONLY" : try(each.value.nat_ip_allocate_option, "AUTO_ONLY")

  nat_ips = try(each.value.reserve_static_ip, false) ? [google_compute_address.nat_ips[each.key].self_link] : []

  source_subnetwork_ip_ranges_to_nat = try(each.value.source_subnetwork_ip_ranges_to_nat, "ALL_SUBNETWORKS_ALL_IP_RANGES")

  log_config {
    enable = try(each.value.nat_log_enable, false)
    filter = try(each.value.filter, "ERRORS_ONLY")
  }
}


