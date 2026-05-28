module "labels" {
  source = "git::https://github.com/terraform-gcloud-modules/terraform-gcp-labels.git?ref=v0.0.1"

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