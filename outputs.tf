
# ══════════════════════════════════════════════════════════════════
# SUBNET OUTPUTS
# All outputs are maps keyed by subnet name
# Usage: module.subnet.subnet_self_links["web"]
# ══════════════════════════════════════════════════════════════════

output "subnet_ids" {
  description = "Map of subnet name → subnet ID. Usage: module.subnet.subnet_ids[\"web\"]"
  value       = { for k, v in google_compute_subnetwork.subnetwork : k => v.id }
}

output "subnet_names" {
  description = "Map of subnet name → full resource name in GCP."
  value       = { for k, v in google_compute_subnetwork.subnetwork : k => v.name }
}

output "subnet_self_links" {
  description = "Map of subnet name → self_link URI. Pass to GKE node pools, VM instances, or other modules."
  value       = { for k, v in google_compute_subnetwork.subnetwork : k => v.self_link }
}

output "subnet_gateway_addresses" {
  description = "Map of subnet name → default gateway IP address."
  value       = { for k, v in google_compute_subnetwork.subnetwork : k => v.gateway_address }
}

output "subnet_ip_cidr_ranges" {
  description = "Map of subnet name → primary CIDR range."
  value       = { for k, v in google_compute_subnetwork.subnetwork : k => v.ip_cidr_range }
}

output "subnet_regions" {
  description = "Map of subnet name → GCP region where subnet lives."
  value       = { for k, v in google_compute_subnetwork.subnetwork : k => v.region }
}

output "subnet_projects" {
  description = "Map of subnet name → GCP project ID."
  value       = { for k, v in google_compute_subnetwork.subnetwork : k => v.project }
}

output "subnet_secondary_ip_ranges" {
  description = "Map of subnet name → list of secondary IP ranges. Useful when passing GKE ranges to other modules."
  value       = { for k, v in google_compute_subnetwork.subnetwork : k => v.secondary_ip_range }
}

# ══════════════════════════════════════════════════════════════════
# FIREWALL OUTPUTS
# ══════════════════════════════════════════════════════════════════

output "firewall_ids" {
  description = "Map of firewall rule name → resource ID."
  value       = { for k, v in google_compute_firewall.rules : k => v.id }
}

output "firewall_self_links" {
  description = "Map of firewall rule name → self_link URI."
  value       = { for k, v in google_compute_firewall.rules : k => v.self_link }
}

# ══════════════════════════════════════════════════════════════════
# ROUTE OUTPUTS
# ══════════════════════════════════════════════════════════════════

output "route_ids" {
  description = "Map of route name → resource ID."
  value       = { for k, v in google_compute_route.routes : k => v.id }
}

output "route_self_links" {
  description = "Map of route name → self_link URI."
  value       = { for k, v in google_compute_route.routes : k => v.self_link }
}

# ══════════════════════════════════════════════════════════════════
# ROUTER OUTPUTS
# ══════════════════════════════════════════════════════════════════

output "router_id" {
  description = "ID of the shared Cloud Router. Empty string if router was not created."
  value       = length(google_compute_router.router) > 0 ? google_compute_router.router[0].id : ""
}

output "router_name" {
  description = "Name of the shared Cloud Router. Use when adding BGP peers or VPN tunnels."
  value       = length(google_compute_router.router) > 0 ? google_compute_router.router[0].name : ""
}

output "router_self_link" {
  description = "Self link of the shared Cloud Router."
  value       = length(google_compute_router.router) > 0 ? google_compute_router.router[0].self_link : ""
}

# ══════════════════════════════════════════════════════════════════
# NAT OUTPUTS
# ══════════════════════════════════════════════════════════════════

output "nat_ids" {
  description = "Map of NAT name → resource ID."
  value       = { for k, v in google_compute_router_nat.nats : k => v.id }
}

output "nat_static_ips" {
  description = "Map of NAT name → reserved static IP address. Only populated for NATs where reserve_static_ip = true."
  value       = { for k, v in google_compute_address.nat_ips : k => v.address }
}

output "nat_static_ip_self_links" {
  description = "Map of NAT name → self_link of the reserved static IP address."
  value       = { for k, v in google_compute_address.nat_ips : k => v.self_link }
}
