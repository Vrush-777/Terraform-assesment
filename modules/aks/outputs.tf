output "aks_cluster_id" {
  description = "ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.fqdn
}

output "aks_kube_config" {
  description = "Kubeconfig for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "aks_client_certificate" {
  description = "Client certificate for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate
  sensitive   = true
}

output "aks_client_key" {
  description = "Client key for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].client_key
  sensitive   = true
}

output "aks_cluster_ca_certificate" {
  description = "Cluster CA certificate for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate
  sensitive   = true
}

output "aks_principal_id" {
  description = "Principal ID of the AKS cluster's system assigned managed identity"
  value       = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}

output "kubelet_identity_id" {
  description = "ID of the kubelet managed identity"
  value       = azurerm_user_assigned_identity.kubelet_identity.id
}

output "kubelet_identity_principal_id" {
  description = "Principal ID of the kubelet managed identity"
  value       = azurerm_user_assigned_identity.kubelet_identity.principal_id
}

output "aks_http_application_routing_zone_name" {
  description = "HTTP Application Routing Zone Name"
  value       = try(azurerm_kubernetes_cluster.aks.http_application_routing_zone_name, null)
}
