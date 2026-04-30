output "acr_id" {
  description = "ID of the Azure Container Registry"
  value       = azurerm_container_registry.acr.id
}

output "acr_name" {
  description = "Name of the Azure Container Registry"
  value       = azurerm_container_registry.acr.name
}

output "acr_login_server" {
  description = "Login server of the Azure Container Registry"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  description = "Admin username of the Azure Container Registry"
  value       = azurerm_container_registry.acr.admin_username
  sensitive   = true
}

output "acr_admin_password" {
  description = "Admin password of the Azure Container Registry"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}

output "private_endpoint_id" {
  description = "ID of the private endpoint (if enabled)"
  value       = try(azurerm_private_endpoint.acr_private_endpoint[0].id, null)
}

output "private_dns_zone_id" {
  description = "ID of the private DNS zone (if enabled)"
  value       = try(azurerm_private_dns_zone.acr_dns_zone[0].id, null)
}
