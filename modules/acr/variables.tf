variable "acr_name" {
  description = "Name of the Azure Container Registry (must be globally unique, alphanumeric only)"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{5,50}$", var.acr_name))
    error_message = "ACR name must be 5-50 lowercase alphanumeric characters."
  }
}

variable "location" {
  description = "Azure region for the ACR"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "sku" {
  description = "SKU of the container registry (Basic, Standard, Premium)"
  type        = string
  default     = "Premium"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be one of: Basic, Standard, Premium."
  }
}

variable "subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
  default     = null
}

variable "vnet_id" {
  description = "Virtual Network ID for private DNS zone link"
  type        = string
  default     = null
}

variable "enable_public_access" {
  description = "Enable public network access to the registry"
  type        = bool
  default     = false
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint for the registry"
  type        = bool
  default     = true
}

variable "acr_private_endpoint_name" {
  description = "Name of the private endpoint for ACR"
  type        = string
  default     = "acr-private-endpoint"
}

variable "acr_private_service_connection_name" {
  description = "Name of the private service connection for ACR"
  type        = string
  default     = "acr-private-service-connection"
}

variable "enable_private_dns_zone" {
  description = "Enable private DNS zone for the registry"
  type        = bool
  default     = true
}

variable "acr_private_dns_link_name" {
  description = "Name of the private DNS zone link for ACR"
  type        = string
  default     = "acr-private-dns-link"
}

variable "enable_encryption" {
  description = "Enable encryption for the registry"
  type        = bool
  default     = true
}

variable "key_vault_key_id" {
  description = "Key Vault key ID for encryption"
  type        = string
  default     = null
}

variable "enable_aks_integration" {
  description = "Enable AKS integration and grant AcrPull role"
  type        = bool
  default     = true
}

variable "aks_principal_id" {
  description = "Principal ID of the AKS kubelet-managed identity used for ACR pulls"
  type        = string
  default     = null
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
