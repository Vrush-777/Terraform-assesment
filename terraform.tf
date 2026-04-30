terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.2"
    }
  }

  # Using local backend for development/testing
  # After creating the storage account, uncomment and update the backend configuration below:
  # backend "azurerm" {
  #   resource_group_name  = "aks-platform-dev-rg"
  #   storage_account_name = "aksplatformdevtfstate"
  #   container_name       = "terraform-state"
  #   key                  = "dev/terraform.tfstate"
  # }
}

provider "azurerm" {
  features {
  }
}

# Data source to get current Azure context
data "azurerm_client_config" "current" {}
