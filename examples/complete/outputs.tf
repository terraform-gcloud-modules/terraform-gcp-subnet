output "subnet_ids" {
  value       = module.subnet.subnet_ids
  description = "Map of subnet name to subnet ID. Example: subnet_ids[\"web\"] = projects/.../subnetworks/..."
}

output "subnet_self_links" {
  value       = module.subnet.subnet_self_links
  description = "Map of subnet name to self_link. Pass individual values to GKE or VM modules."
}

output "subnet_gateway_addresses" {
  value       = module.subnet.subnet_gateway_addresses
  description = "Map of subnet name to gateway IP."
}