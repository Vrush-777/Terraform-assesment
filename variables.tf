variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "aks-platform"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

# Storage Account variables
variable "storage_account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

variable "storage_account_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "GRS"
}

variable "terraform_state_container_name" {
  description = "Container name for Terraform state"
  type        = string
  default     = "terraform-state"
}

# Network variables
variable "address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "aks_subnet_address_prefix" {
  description = "Address prefix for AKS subnet"
  type        = list(string)
  default     = ["[REDACTED_IPV4_ADDRESS_2]/24"]
}

variable "acr_subnet_address_prefix" {
  description = "Address prefix for ACR subnet"
  type        = list(string)
  default     = ["[REDACTED_IPV4_ADDRESS_4]/24"]
}

# ACR variables
variable "acr_sku" {
  description = "ACR SKU"
  type        = string
  default     = "Basic"
}

variable "enable_acr_public_access" {
  description = "Enable public access to ACR"
  type        = bool
  default     = false
}

variable "enable_acr_private_endpoint" {
  description = "Enable private endpoint for ACR"
  type        = bool
  default     = true
}

variable "enable_acr_private_dns_zone" {
  description = "Enable private DNS zone for ACR"
  type        = bool
  default     = true
}

variable "enable_acr_encryption" {
  description = "Enable encryption for ACR"
  type        = bool
  default     = true
}

variable "key_vault_key_id" {
  description = "Key Vault key ID for ACR encryption"
  type        = string
  default     = null
}

# AKS variables
variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = null
}

variable "node_pool_name" {
  description = "Default node pool name"
  type        = string
  default     = "default"
}

variable "node_count" {
  description = "Number of nodes"
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "VM size for nodes"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB"
  type        = number
  default     = 100
}

variable "max_pods" {
  description = "Maximum pods per node"
  type        = number
  default     = 110
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = []
}

variable "network_plugin" {
  description = "Network plugin"
  type        = string
  default     = "azure"
}

variable "network_policy" {
  description = "Network policy"
  type        = string
  default     = "azure"
}

variable "service_cidr" {
  description = "Service CIDR"
  type        = string
  default     = "172.16.0.0/16"
}

variable "dns_service_ip" {
  description = "DNS service IP"
  type        = string
  default     = "172.16.0.10"
}

variable "docker_bridge_cidr" {
  description = "Docker bridge CIDR"
  type        = string
  default     = "172.17.0.1/16"
}

variable "load_balancer_sku" {
  description = "Load balancer SKU"
  type        = string
  default     = "standard"
}

variable "outbound_type" {
  description = "Outbound type"
  type        = string
  default     = "loadBalancer"
}

variable "admin_group_object_ids" {
  description = "AAD group IDs for cluster admin"
  type        = list(string)
  default     = []
}

variable "authorized_ip_ranges" {
  description = "Authorized IP ranges for API server"
  type        = list(string)
  default     = []
}

variable "enable_azure_policy" {
  description = "Enable Azure Policy"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  type        = string
  default     = null
}

# Additional node pool variables
variable "create_additional_node_pool" {
  description = "Create additional node pool"
  type        = bool
  default     = false
}

variable "additional_node_pool_name" {
  description = "Additional node pool name"
  type        = string
  default     = "workload"
}

variable "additional_node_count" {
  description = "Number of nodes in additional pool"
  type        = number
  default     = 2
}

variable "additional_vm_size" {
  description = "VM size for additional pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "additional_node_labels" {
  description = "Labels for additional nodes"
  type        = map(string)
  default     = {}
}

variable "additional_node_taints" {
  description = "Taints for additional nodes"
  type        = list(string)
  default     = []
}

# System node pool variables
variable "enable_system_pool" {
  description = "Enable system node pool"
  type        = bool
  default     = false
}

variable "system_node_count" {
  description = "Number of system nodes"
  type        = number
  default     = 1
}

variable "system_vm_size" {
  description = "VM size for system pool"
  type        = string
  default     = "Standard_D2s_v3"
}

# Tags
variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

