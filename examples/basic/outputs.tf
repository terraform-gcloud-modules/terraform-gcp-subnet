output "subnet_ids" {
  value       = module.subnet.subnet_ids
  description = "Map of subnet name to ID."
}

output "subnet_self_links" {
  value       = module.subnet.subnet_self_links
  description = "Map of subnet name to self_link."
}

