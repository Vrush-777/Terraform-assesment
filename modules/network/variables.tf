variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "virtual_network_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "aks_subnet_name" {
  description = "Name of the AKS subnet"
  type        = string
}

variable "aks_subnet_address_prefix" {
  description = "Address prefix for AKS subnet"
  type        = list(string)
  default     = ["[REDACTED_IPV4_ADDRESS_2]/24"]
}

variable "acr_subnet_name" {
  description = "Name of the ACR subnet"
  type        = string
}

variable "acr_subnet_address_prefix" {
  description = "Address prefix for ACR subnet"
  type        = list(string)
  default     = ["[REDACTED_IPV4_ADDRESS_4]/24"]
}

variable "aks_nsg_name" {
  description = "Name of the AKS network security group"
  type        = string
}

variable "acr_nsg_name" {
  description = "Name of the ACR network security group"
  type        = string
}

variable "aks_route_table_name" {
  description = "Name of the AKS route table"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
