output "virtual_network_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "virtual_network_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output "aks_subnet_id" {
  description = "ID of the AKS subnet"
  value       = azurerm_subnet.aks_subnet.id
}

output "aks_subnet_name" {
  description = "Name of the AKS subnet"
  value       = azurerm_subnet.aks_subnet.name
}

output "acr_subnet_id" {
  description = "ID of the ACR subnet"
  value       = azurerm_subnet.acr_subnet.id
}

output "acr_subnet_name" {
  description = "Name of the ACR subnet"
  value       = azurerm_subnet.acr_subnet.name
}

output "aks_nsg_id" {
  description = "ID of the AKS network security group"
  value       = azurerm_network_security_group.aks_nsg.id
}

output "acr_nsg_id" {
  description = "ID of the ACR network security group"
  value       = azurerm_network_security_group.acr_nsg.id
}
