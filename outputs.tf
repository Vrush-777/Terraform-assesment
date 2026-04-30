output "resource_group_name" {
  description = "Name of the created resource group"
  value       = module.resource_group.resource_group_name
}

output "resource_group_id" {
  description = "ID of the created resource group"
  value       = module.resource_group.resource_group_id
}

output "storage_account_id" {
  description = "ID of the Terraform state storage account"
  value       = module.storage_account.storage_account_id
}

output "storage_account_name" {
  description = "Name of the Terraform state storage account"
  value       = module.storage_account.storage_account_name
}

output "terraform_state_container_name" {
  description = "Name of the Terraform state container"
  value       = module.storage_account.container_name
}

# Commented out outputs for disabled modules - uncomment when modules are enabled
# output "virtual_network_id" {
#   description = "ID of the virtual network"
#   value       = module.network.virtual_network_id
# }
# 
# output "virtual_network_name" {
#   description = "Name of the virtual network"
#   value       = module.network.virtual_network_name
# }
# 
# output "aks_subnet_id" {
#   description = "ID of the AKS subnet"
#   value       = module.network.aks_subnet_id
# }
# 
# output "acr_id" {
#   description = "ID of the Azure Container Registry"
#   value       = module.acr.acr_id
# }
# 
# output "acr_name" {
#   description = "Name of the Azure Container Registry"
#   value       = module.acr.acr_name
# }
# 
# output "acr_login_server" {
#   description = "Login server of the Azure Container Registry"
#   value       = module.acr.acr_login_server
# }
# 
# output "aks_cluster_id" {
#   description = "ID of the AKS cluster"
#   value       = module.aks.aks_cluster_id
# }
# 
# output "aks_cluster_name" {
#   description = "Name of the AKS cluster"
#   value       = module.aks.aks_cluster_name
# }
# 
# output "aks_fqdn" {
#   description = "FQDN of the AKS cluster"
#   value       = module.aks.aks_fqdn
# }
# 
# output "aks_kube_config" {
#   description = "Kubeconfig for the AKS cluster"
#   value       = module.aks.aks_kube_config
#   sensitive   = true
# }
# 
# output "connection_info" {
#   description = "Connection information for the AKS cluster"
#   value = {
#     cluster_name      = module.aks.aks_cluster_name
#     cluster_fqdn      = module.aks.aks_fqdn
#     resource_group    = module.resource_group.resource_group_name
#     location          = var.location
#     acr_login_server  = module.acr.acr_login_server
#   }
# }
