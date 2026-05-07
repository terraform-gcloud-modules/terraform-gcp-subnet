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

output "firewall_ids" {
  value       = module.subnet.firewall_ids
  description = "Map of firewall rule name to ID."
}

output "route_ids" {
  value       = module.subnet.route_ids
  description = "Map of route name to ID."
}

output "router_name" {
  value       = module.subnet.router_name
  description = "Name of the shared Cloud Router."
}

output "nat_ids" {
  value       = module.subnet.nat_ids
  description = "Map of NAT name to ID."
}

output "nat_static_ips" {
  value       = module.subnet.nat_static_ips
  description = "Map of NAT name to reserved static IP. Only for NATs with reserve_static_ip=true."
}