resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku

  admin_enabled                        = false
  public_network_access_enabled        = var.enable_public_access
  network_rule_bypass_option           = "AzureServices"
  anonymous_pull_enabled               = false
  data_endpoint_enabled                = true

  # Encryption can be enabled with Key Vault key
  # Uncomment and configure when Key Vault is available
  # encryption {
  #   enabled            = true
  #   key_vault_key_id   = var.key_vault_key_id
  #   identity_client_id = null  # Use system assigned identity
  # }

  tags = var.common_tags
}

# Private endpoint for ACR
resource "azurerm_private_endpoint" "acr_private_endpoint" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = var.acr_private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = var.acr_private_service_connection_name
    private_connection_resource_id = azurerm_container_registry.acr.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  tags = var.common_tags
}

# Private DNS Zone for ACR (optional, recommended for private endpoints)
resource "azurerm_private_dns_zone" "acr_dns_zone" {
  count               = var.enable_private_dns_zone ? 1 : 0
  name                = "privatelink.azurecr.io"
  resource_group_name = var.resource_group_name

  tags = var.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr_dns_vnet_link" {
  count                 = var.enable_private_dns_zone ? 1 : 0
  name                  = var.acr_private_dns_link_name
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.acr_dns_zone[0].name
  virtual_network_id    = var.vnet_id
  registration_enabled  = true

  tags = var.common_tags
}

# Role Assignment for AKS to pull images from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  count              = var.enable_aks_integration ? 1 : 0
  scope              = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id       = var.aks_principal_id
}
