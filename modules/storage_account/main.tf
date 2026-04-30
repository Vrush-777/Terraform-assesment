resource "azurerm_storage_account" "backend" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  https_traffic_only_enabled = true
  min_tls_version          = "TLS1_2"

  # Enable encryption at rest
  identity {
    type = "SystemAssigned"
  }

  tags = var.common_tags
}

resource "azurerm_storage_container" "terraform_state" {
  name                 = var.container_name
  storage_account_id   = azurerm_storage_account.backend.id
  container_access_type = "private"
}

resource "azurerm_management_lock" "terraform_state_lock" {
  name       = "terraform-state-lock"
  scope      = azurerm_storage_account.backend.id
  lock_level = "CanNotDelete"
  depends_on = [
    azurerm_storage_account.backend
  ]
}
