locals {
  # Naming conventions
  name_prefix            = "${var.project_name}-${var.environment}"
  resource_group_name    = "${local.name_prefix}-rg"
  storage_account_name   = replace("${local.name_prefix}tfstate", "-", "")
  vnet_name              = "${local.name_prefix}-vnet"
  aks_subnet_name        = "${local.name_prefix}-aks-subnet"
  acr_subnet_name        = "${local.name_prefix}-acr-subnet"
  aks_nsg_name           = "${local.name_prefix}-aks-nsg"
  acr_nsg_name           = "${local.name_prefix}-acr-nsg"
  aks_route_table_name   = "${local.name_prefix}-aks-rt"
  acr_name               = replace("${local.name_prefix}acr", "-", "")
  aks_cluster_name       = "${local.name_prefix}-aks"
  dns_prefix             = "${local.name_prefix}-dns"
  aks_identity_name      = "${local.name_prefix}-aks-identity"
  kubelet_identity_name  = "${local.name_prefix}-kubelet-identity"

  # Common tags
  common_tags = merge(
    var.common_tags,
    {
      "Environment" = var.environment
      "Project"     = var.project_name
      "Terraform"   = "true"
      "ManagedBy"   = "Terraform"
    }
  )
}
