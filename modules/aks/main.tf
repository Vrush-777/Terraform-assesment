resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  # Node pool configuration
  default_node_pool {
    name                = var.node_pool_name
    node_count          = var.node_count
    vm_size             = var.vm_size
    os_disk_size_gb     = var.os_disk_size_gb
    vnet_subnet_id      = var.subnet_id
    max_pods            = var.max_pods
    #availability_zones  = var.availability_zones

    tags = var.common_tags
  }

  # Cluster identity configuration
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_identity.id]
  }

  # Network profile
  network_profile {
    network_plugin      = var.network_plugin
    network_policy      = var.network_policy
    service_cidr        = var.service_cidr
    dns_service_ip      = var.dns_service_ip
    #docker_bridge_cidr  = var.docker_bridge_cidr  # Not supported in current Azure provider
    load_balancer_sku   = var.load_balancer_sku
    outbound_type       = var.outbound_type
  }

  # Role-Based Access Control
  role_based_access_control_enabled = true
  azure_active_directory_role_based_access_control {
    #managed                = true
    azure_rbac_enabled     = true
    admin_group_object_ids = var.admin_group_object_ids
  }

  # API Server Access Control
  api_server_access_profile {
    authorized_ip_ranges = var.authorized_ip_ranges
  }

  # Azure Policy addon
  azure_policy_enabled = var.enable_azure_policy

  # HTTP Application Routing (optional)
  http_application_routing_enabled = false

  # Monitoring addon
  #oms_agent {
    #log_analytics_workspace_id = var.log_analytics_workspace_id
  #}

  # Kubelet identity
  kubelet_identity {
    client_id                 = azurerm_user_assigned_identity.kubelet_identity.client_id
    object_id                 = azurerm_user_assigned_identity.kubelet_identity.principal_id
    user_assigned_identity_id = azurerm_user_assigned_identity.kubelet_identity.id
  }

  tags = var.common_tags

  depends_on = [azurerm_role_assignment.aks_kubelet_mio]
}

# User-assigned managed identity for AKS control plane
resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = var.aks_identity_name
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.common_tags
}

# User-assigned managed identity for kubelet
resource "azurerm_user_assigned_identity" "kubelet_identity" {
  name                = var.kubelet_identity_name
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.common_tags
}

# Role assignments for cluster identity
resource "azurerm_role_assignment" "cluster_managed_identity_network_contributor" {
  scope               = var.subnet_id
  role_definition_name = "Network Contributor"
  principal_id        = azurerm_user_assigned_identity.aks_identity.principal_id
}

resource "azurerm_role_assignment" "aks_kubelet_mio" {
  scope                = azurerm_user_assigned_identity.kubelet_identity.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}

# Role assignments for kubelet identity
resource "azurerm_role_assignment" "kubelet_managed_identity_network_contributor" {
  scope               = var.subnet_id
  role_definition_name = "Network Contributor"
  principal_id        = azurerm_user_assigned_identity.kubelet_identity.principal_id
}

# Additional node pool (optional)
resource "azurerm_kubernetes_cluster_node_pool" "additional_nodes" {
  count                 = var.create_additional_node_pool ? 1 : 0
  name                  = var.additional_node_pool_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  node_count            = var.additional_node_count
  vm_size               = var.additional_vm_size
  vnet_subnet_id        = var.subnet_id
  max_pods              = var.max_pods
  #availability_zones    = var.availability_zones
  node_labels           = var.additional_node_labels
  node_taints           = var.additional_node_taints

  tags = var.common_tags
}

# Auto scaler for default node pool
resource "azurerm_kubernetes_cluster_node_pool" "system_pool" {
  count                 = var.enable_system_pool ? 1 : 0
  name                  = "system"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  node_count            = var.system_node_count
  vm_size               = var.system_vm_size
  vnet_subnet_id        = var.subnet_id
  #availability_zones    = var.availability_zones
  node_labels = {
    "workload-type" = "system"
  }

  tags = var.common_tags
}
