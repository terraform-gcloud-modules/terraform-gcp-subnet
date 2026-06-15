
# ----------------------------------------------------------------------------------
# SUBNET OUTPUTS
# ----------------------------------------------------------------------------------

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
