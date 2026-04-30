variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "location" {
  description = "Azure region for the AKS cluster"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version to use"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Subnet ID for the AKS cluster nodes"
  type        = string
}

# ---------------- NODE CONFIG ----------------

variable "node_pool_name" {
  description = "Name of the default node pool"
  type        = string
  default     = "default"
}

variable "node_count" {
  description = "Initial number of nodes"
  type        = number
  default     = 1

  validation {
    condition     = var.node_count >= 1 && var.node_count <= 10
    error_message = "Node count must be between 1 and 10."
  }
}

variable "vm_size" {
  description = "VM size"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "os_disk_size_gb" {
  description = "OS disk size"
  type        = number
  default     = 100
}

variable "max_pods" {
  description = "Max pods per node"
  type        = number
  default     = 30
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for z in var.availability_zones : contains(["1", "2", "3"], z)
    ])
    error_message = "Zones must be 1, 2, or 3."
  }
}

# ---------------- NETWORK CONFIG ----------------

variable "network_plugin" {
  description = "Network plugin"
  type        = string
  default     = "azure"

  validation {
    condition     = contains(["azure", "kubenet"], var.network_plugin)
    error_message = "Must be azure or kubenet."
  }
}

variable "network_policy" {
  description = "Network policy"
  type        = string
  default     = "azure"

  validation {
    condition     = contains(["azure", "calico"], var.network_policy)
    error_message = "Must be azure or calico."
  }
}

variable "service_cidr" {
  description = "CIDR for Kubernetes services"
  type        = string
  default     = "172.16.0.0/16"

  validation {
    condition     = can(cidrhost(var.service_cidr, 0))
    error_message = "Must be a valid CIDR block."
  }
}

variable "dns_service_ip" {
  description = "DNS IP inside service CIDR"
  type        = string
  default     = "172.16.0.10"
}

variable "load_balancer_sku" {
  description = "Load balancer SKU"
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "basic"], var.load_balancer_sku)
    error_message = "Load balancer SKU must be standard or basic."
  }
}

variable "outbound_type" {
  description = "Outbound type"
  type        = string
  default     = "loadBalancer"
}

# ---------------- SECURITY / RBAC ----------------

variable "admin_group_object_ids" {
  description = "AAD group IDs for admin access"
  type        = list(string)
  default     = []
}

variable "authorized_ip_ranges" {
  description = "Allowed IP ranges for API server"
  type        = list(string)
  default     = []
}

# ---------------- MONITORING ----------------

variable "enable_azure_policy" {
  description = "Enable Azure Policy"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  type        = string
  default     = null
}

# ---------------- KUBELET IDENTITY ----------------

variable "aks_identity_name" {
  description = "Name of the AKS cluster managed identity"
  type        = string
}

variable "kubelet_identity_name" {
  description = "Name of the kubelet managed identity"
  type        = string
}

# ---------------- DOCKER BRIDGE CIDR ----------------

variable "docker_bridge_cidr" {
  description = "Docker bridge CIDR for network plugin"
  type        = string
  default     = null
}

# ---------------- ADDITIONAL NODE POOL ----------------

variable "create_additional_node_pool" {
  description = "Create an additional node pool"
  type        = bool
  default     = false
}

variable "additional_node_pool_name" {
  description = "Name of the additional node pool"
  type        = string
  default     = "workload"
}

variable "additional_node_count" {
  description = "Number of nodes in the additional pool"
  type        = number
  default     = 2

  validation {
    condition     = var.additional_node_count >= 1 && var.additional_node_count <= 10
    error_message = "Additional node count must be between 1 and 10."
  }
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
  description = "Taints for additional nodes (format: key=value:effect)"
  type        = list(string)
  default     = []
}

# ---------------- SYSTEM NODE POOL ----------------

variable "enable_system_pool" {
  description = "Enable a dedicated system node pool"
  type        = bool
  default     = false
}

variable "system_node_count" {
  description = "Number of nodes in the system pool"
  type        = number
  default     = 1

  validation {
    condition     = var.system_node_count >= 1 && var.system_node_count <= 10
    error_message = "System node count must be between 1 and 10."
  }
}

variable "system_vm_size" {
  description = "VM size for system pool"
  type        = string
  default     = "Standard_D2s_v3"
}

# ---------------- TAGS ----------------

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}