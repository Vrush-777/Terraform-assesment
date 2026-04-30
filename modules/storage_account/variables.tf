variable "storage_account_name" {
  description = "Name of the storage account (must be globally unique, lowercase alphanumeric only)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name must be 3-24 lowercase alphanumeric characters."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "account_tier" {
  description = "Tier of the storage account (Standard or Premium)"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Account tier must be either 'Standard' or 'Premium'."
  }
}

variable "account_replication_type" {
  description = "Replication type (LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS)"
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "Invalid replication type."
  }
}

variable "container_name" {
  description = "Name of the blob container for Terraform state"
  type        = string
  default     = "tfstate"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)

  default = {
    environment = "dev"
    project     = "terraform-assessment"
    owner       = "vrushali"
  }
}