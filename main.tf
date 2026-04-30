# Resource Group
module "resource_group" {
  source = "./modules/resource_group"

  resource_group_name = local.resource_group_name
  location            = var.location
  common_tags         = local.common_tags
}

# Storage Account for Terraform State
module "storage_account" {
  source = "./modules/storage_account"

  storage_account_name      = local.storage_account_name
  resource_group_name       = module.resource_group.resource_group_name
  location                  = var.location
  account_tier              = var.storage_account_tier
  account_replication_type  = var.storage_account_replication_type
  container_name            = var.terraform_state_container_name
  common_tags               = local.common_tags
}

#Virtual Network and Networking Components (commented out for initial setup)
#Uncomment after resource group and storage account are created
module "network" {
  source = "./modules/network"

  location            = var.location
  resource_group_name = module.resource_group.resource_group_name

  virtual_network_name   = local.vnet_name
  address_space          = var.address_space
  aks_subnet_name        = local.aks_subnet_name
  aks_subnet_address_prefix = var.aks_subnet_address_prefix
  acr_subnet_name        = local.acr_subnet_name
  acr_subnet_address_prefix = var.acr_subnet_address_prefix
  aks_nsg_name           = local.aks_nsg_name
  acr_nsg_name           = local.acr_nsg_name
  aks_route_table_name   = local.aks_route_table_name

  common_tags = local.common_tags

  depends_on = [module.resource_group]
}

# Azure Container Registry (commented out for initial setup)
module "acr" {
  source = "./modules/acr"

  acr_name               = local.acr_name
  location               = var.location
  resource_group_name    = module.resource_group.resource_group_name
  sku                    = var.acr_sku
  subnet_id              = module.network.acr_subnet_id
  vnet_id                = module.network.virtual_network_id
  enable_public_access   = var.enable_acr_public_access
  enable_private_endpoint = var.enable_acr_private_endpoint
  enable_private_dns_zone = var.enable_acr_private_dns_zone
  enable_encryption      = var.enable_acr_encryption
  enable_aks_integration = true
  aks_principal_id       = module.aks.kubelet_identity_principal_id

  common_tags = local.common_tags

  depends_on = [module.network]
}

# Azure Kubernetes Service (commented out for initial setup)
module "aks" {
  source = "./modules/aks"

  aks_cluster_name       = local.aks_cluster_name
  location               = var.location
  resource_group_name    = module.resource_group.resource_group_name
  dns_prefix             = local.dns_prefix
  kubernetes_version     = var.kubernetes_version
  subnet_id              = module.network.aks_subnet_id
  node_pool_name         = var.node_pool_name
  node_count             = var.node_count
  vm_size                = var.vm_size
  os_disk_size_gb        = var.os_disk_size_gb
  max_pods               = var.max_pods
  availability_zones     = var.availability_zones
  network_plugin         = var.network_plugin
  network_policy         = var.network_policy
  service_cidr           = var.service_cidr
  dns_service_ip         = var.dns_service_ip
  # docker_bridge_cidr is not supported in the current Azure provider version
  load_balancer_sku      = var.load_balancer_sku
  outbound_type          = var.outbound_type
  admin_group_object_ids = var.admin_group_object_ids
  authorized_ip_ranges   = var.authorized_ip_ranges
  enable_azure_policy    = var.enable_azure_policy
  log_analytics_workspace_id = var.log_analytics_workspace_id
  aks_identity_name         = local.aks_identity_name
  kubelet_identity_name     = local.kubelet_identity_name

  create_additional_node_pool = var.create_additional_node_pool
  additional_node_pool_name   = var.additional_node_pool_name
  additional_node_count       = var.additional_node_count
  additional_vm_size          = var.additional_vm_size
  additional_node_labels      = var.additional_node_labels
  additional_node_taints      = var.additional_node_taints

  enable_system_pool = var.enable_system_pool
  system_node_count  = var.system_node_count
  system_vm_size     = var.system_vm_size

  common_tags = local.common_tags

  depends_on = [module.network]
}

