output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.backend.id
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.backend.name
}

output "storage_account_primary_blob_endpoint" {
  description = "Primary blob endpoint for the storage account"
  value       = azurerm_storage_account.backend.primary_blob_endpoint
}

output "container_name" {
  description = "Name of the blob container"
  value       = azurerm_storage_container.terraform_state.name
}

output "container_id" {
  description = "ID of the blob container"
  value       = azurerm_storage_container.terraform_state.id
}
