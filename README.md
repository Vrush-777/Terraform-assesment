# Terraform + AKS Infrastructure as Code Project

## 📋 Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Deployment Guide](#deployment-guide)
- [Module Details](#module-details)
- [Outputs](#outputs)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

## 🎯 Overview

This project provides a complete, production-ready Infrastructure as Code (IaC) solution for deploying an Azure Kubernetes Service (AKS) platform using Terraform. The infrastructure includes:

- **Azure Kubernetes Service (AKS)**: Managed Kubernetes cluster
- **Azure Container Registry (ACR)**: Private container image registry
- **Networking**: VNet, Subnets, NSGs, and Private Endpoints
- **Remote State Management**: Azure Storage Account for team collaboration
- **Security**: Managed Identities, RBAC, Private Endpoints, and Policy enforcement
- **Modularity**: Reusable, maintainable Terraform modules

### Key Features

✅ **Fully Automated**: Deploy entire infrastructure with a single command  
✅ **Modular Architecture**: Separate modules for network, AKS, ACR, and storage  
✅ **Remote State**: Terraform state managed in Azure Blob Storage  
✅ **Production-Ready**: Security, monitoring, and high availability built-in  
✅ **Multi-Environment Support**: Dev, staging, and production configurations  
✅ **Cost Optimized**: Configurable resource sizes and availability zones  

## 📁 Project Structure

```
Terraform-assesment/
├── main.tf                      # Root module - orchestrates all resources
├── variables.tf                 # Input variables with validation
├── outputs.tf                   # Output values for reference
├── locals.tf                    # Local values and naming conventions
├── terraform.tf                 # Terraform version and provider configuration
│
├── modules/                     # Reusable infrastructure modules
│   ├── resource_group/          # Azure Resource Group
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── network/                 # VNet, Subnets, NSGs, Route Tables
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── aks/                     # Azure Kubernetes Service
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── acr/                     # Azure Container Registry
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── storage_account/         # Storage for Terraform state
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── environments/                # Environment-specific configurations
│   ├── dev.tfvars              # Development environment
│   └── prod.tfvars             # Production environment
│
└── README.md                    # This file
```

## 🔧 Prerequisites

Before deploying, ensure you have:

1. **Terraform** (>= 1.0)
   ```powershell
   # On Windows with Chocolatey
   choco install terraform
   
   # Or download from: https://www.terraform.io/downloads
   ```

2. **Azure CLI** (>= 2.40)
   ```powershell
   # On Windows
   winget install Microsoft.AzureCLI
   ```

3. **kubectl** (for cluster management)
   ```powershell
   # Install with Azure CLI
   az aks install-cli
   ```

4. **Azure Subscription** with appropriate permissions

5. **Git** (recommended, for version control)

## 🚀 Getting Started

### Step 1: Initialize Azure Authentication

```bash
az login
az account set --subscription <SUBSCRIPTION_ID>
```

### Step 2: Clone or Download the Project

```bash
# If using Git
git clone <repository-url>
cd Terraform-assesment

# Or navigate to your local copy
cd c:\Users\vrushali.raskar\Terraform-assesment
```

### Step 3: Create Backend Storage (One-time setup)

Before initializing Terraform, create the storage account for remote state:

```powershell
# Variables
$RESOURCE_GROUP = "terraform-state-rg"
$STORAGE_ACCOUNT = "tfstatestg$(Get-Random -Minimum 1000 -Maximum 9999)"
$LOCATION = "eastus"
$CONTAINER = "terraform-state"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create storage account
az storage account create `
  --name $STORAGE_ACCOUNT `
  --resource-group $RESOURCE_GROUP `
  --location $LOCATION `
  --sku Standard_GRS `
  --encryption-services blob

# Get storage account key
$STORAGE_KEY = az storage account keys list `
  --account-name $STORAGE_ACCOUNT `
  --resource-group $RESOURCE_GROUP `
  --query '[0].value' -o tsv

# Create blob container
az storage container create `
  --name $CONTAINER `
  --account-name $STORAGE_ACCOUNT `
  --account-key $STORAGE_KEY

# Note these values for the next step
Write-Host "Storage Account Name: $STORAGE_ACCOUNT"
Write-Host "Storage Account Key: $STORAGE_KEY"
Write-Host "Container Name: $CONTAINER"
```

### Step 4: Initialize Terraform

```powershell
# Navigate to project directory
cd Terraform-assesment

# Initialize with backend configuration
terraform init `
  -backend-config="resource_group_name=terraform-state-rg" `
  -backend-config="storage_account_name=<STORAGE_ACCOUNT_NAME>" `
  -backend-config="container_name=terraform-state" `
  -backend-config="key=dev/terraform.tfstate"
```

### Step 5: Plan Deployment

```bash
# View what will be created
terraform plan -var-file=environments/dev.tfvars -out=tfplan

# For production
terraform plan -var-file=environments/prod.tfvars -out=tfplan
```

### Step 6: Apply Configuration

```bash
# Deploy the infrastructure
terraform apply tfplan
```

## 📊 Deployment Guide

### Deployment Workflow

```
1. terraform init    → Initialize Terraform with backend
2. terraform validate → Validate configuration syntax
3. terraform plan    → Generate deployment plan
4. terraform apply   → Deploy infrastructure
```

### Step-by-Step Deployment

#### 1. Validate Configuration
```bash
terraform validate
```

#### 2. Format Code (Optional)
```bash
terraform fmt -recursive
```

#### 3. Plan Deployment
```bash
terraform plan -var-file=environments/dev.tfvars -out=tfplan
```

#### 4. Apply Configuration
```bash
terraform apply tfplan
```

#### 5. Verify Deployment
```bash
# Get kubeconfig
az aks get-credentials `
  --resource-group <RESOURCE_GROUP> `
  --name <AKS_CLUSTER_NAME>

# Test cluster access
kubectl cluster-info
kubectl get nodes
```

## 📦 Module Details

### 1. Resource Group Module
Creates the Azure Resource Group to contain all resources.

**Key Resources:**
- `azurerm_resource_group`

**Variables:**
- `resource_group_name`: Name of the resource group
- `location`: Azure region
- `common_tags`: Tags for all resources

### 2. Network Module
Creates VNet, Subnets, NSGs, and Route Tables with proper segmentation.

**Key Resources:**
- `azurerm_virtual_network`: Virtual Network
- `azurerm_subnet`: AKS and ACR subnets
- `azurerm_network_security_group`: Security rules
- `azurerm_route_table`: Custom routes

**Features:**
- Service endpoints for container services
- Network security rules for pod communication
- Route table for traffic management

### 3. AKS Module
Deploys the managed Kubernetes cluster with RBAC and monitoring.

**Key Resources:**
- `azurerm_kubernetes_cluster`: AKS cluster
- `azurerm_kubernetes_cluster_node_pool`: Additional node pools
- `azurerm_user_assigned_identity`: Kubelet identity
- `azurerm_role_assignment`: RBAC permissions

**Features:**
- Multiple node pools
- Managed identity
- Azure Policy enforcement
- Network policies (Azure CNI)
- Private API server access control

### 4. ACR Module
Deploys the private container registry with security controls.

**Key Resources:**
- `azurerm_container_registry`: Container registry
- `azurerm_private_endpoint`: Private endpoint
- `azurerm_private_dns_zone`: Private DNS

**Features:**
- Private endpoints for security
- Encryption at rest
- Role-based access control
- Integration with AKS

### 5. Storage Account Module
Creates the remote state storage with protection.

**Key Resources:**
- `azurerm_storage_account`: Storage account
- `azurerm_storage_container`: Blob container
- `azurerm_management_lock`: Protection against deletion

**Features:**
- Versioning enabled
- GRS replication
- HTTPS only
- Deletion lock

## 📤 Outputs

After deployment, Terraform will output:

```bash
# Get all outputs
terraform output

# Get specific output
terraform output aks_cluster_name
terraform output acr_login_server
terraform output aks_fqdn
```

Key outputs include:
- **resource_group_name**: Resource Group name
- **aks_cluster_name**: AKS cluster name
- **aks_fqdn**: AKS API server FQDN
- **aks_kube_config**: Kubeconfig for cluster access
- **acr_login_server**: ACR login server URL
- **storage_account_name**: Terraform state storage account

## 🔐 Security Best Practices

### 1. State File Protection
- Remote state stored in Azure Blob Storage
- Encryption at rest enabled
- Versioning enabled for recovery
- Deletion lock applied

### 2. Access Control
- Managed identities for all services
- RBAC with least privilege
- AAD integration for cluster admin
- API server access control lists

### 3. Network Security
- Private endpoints for ACR
- Network Security Groups
- Service endpoints
- Network policies (Azure CNI)

### 4. Encryption
- ACR encryption with Key Vault (optional)
- TLS for all communications
- HTTPS-only storage

## 🔄 Scaling and Customization

### Add Additional Node Pool
```hcl
# In variables.tf or tfvars
create_additional_node_pool = true
additional_node_pool_name = "workload"
additional_node_count = 3
additional_vm_size = "Standard_D4s_v3"
additional_node_labels = {
  "workload-type" = "compute"
}
```

### Change AKS Configuration
Edit `environments/dev.tfvars` or `environments/prod.tfvars`:
```hcl
node_count = 5
vm_size = "Standard_D4s_v3"
kubernetes_version = "1.27"
```

### Update ACR Settings
```hcl
acr_sku = "Premium"
enable_acr_public_access = false
```

## 🐛 Troubleshooting

### Issue: "Insufficient permissions"
**Solution:** Ensure your Azure account has Owner or Contributor role on the subscription.

### Issue: "Storage account name not available"
**Solution:** Storage account names must be globally unique. Use a different name.

### Issue: "Terraform state lock timeout"
**Solution:** Another deployment is in progress. Wait or check Azure portal for stuck deployments.

### Issue: "AKS node pool deployment failed"
**Solution:** 
- Check subnet CIDR range conflicts
- Verify Kubernetes version availability in region
- Check Azure quotas for compute resources

### Get Cluster Credentials
```bash
az aks get-credentials \
  --resource-group <RESOURCE_GROUP> \
  --name <AKS_CLUSTER_NAME>
```

### Check Cluster Status
```bash
kubectl cluster-info
kubectl get nodes
kubectl get namespaces
```

## 📋 Best Practices

### 1. State Management
```bash
# Always use remote state
# Backup state file regularly
terraform state pull > terraform.state.backup

# Lock state during operations (automatic)
# Use terraform plan before apply
```

### 2. Code Organization
```bash
# Use environments for different configurations
terraform plan -var-file=environments/dev.tfvars

# Maintain consistent naming conventions
# Use locals.tf for centralized naming
```

### 3. Change Management
```bash
# Always review plan output
terraform plan -var-file=environments/prod.tfvars

# Use version control
git commit -m "Update AKS cluster to v1.27"
```

### 4. Monitoring and Logging
```bash
# Enable Log Analytics workspace
log_analytics_workspace_id = "/subscriptions/.../providers/Microsoft.OperationalInsights/workspaces/..."

# Monitor cluster health
az aks show --name <CLUSTER_NAME> --resource-group <RG_NAME>
```

### 5. Cost Optimization
- Use Standard_D2s_v3 for dev environments
- Use Standard_D4s_v3 for production
- Consider spot instances for non-critical workloads
- Review Azure recommendations regularly

## 🔄 Updating Infrastructure

### Update Terraform Code
```bash
# Make changes to .tf files
# Plan the changes
terraform plan -var-file=environments/dev.tfvars -out=tfplan

# Review changes
# Apply when ready
terraform apply tfplan
```

### Update Variables
Edit `environments/dev.tfvars` or `environments/prod.tfvars`:
```bash
terraform apply -var-file=environments/dev.tfvars
```

## 🗑️ Destroying Infrastructure

### Complete Cleanup
```bash
# WARNING: This destroys all resources
terraform destroy -var-file=environments/dev.tfvars

# Confirm when prompted
```

### Keep Specific Resources
Modify code to remove resources before running destroy, or manually delete from Azure portal.

## 📚 Additional Resources

- [Terraform Azure Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [AKS Best Practices](https://learn.microsoft.com/en-us/azure/aks/best-practices)
- [Terraform Best Practices](https://developer.hashicorp.com/terraform/cloud-docs/recommended-practices)
- [Azure Architecture Center](https://learn.microsoft.com/en-us/azure/architecture/)

## 📞 Support

For issues or questions:
1. Check the Troubleshooting section
2. Review Terraform logs: `TF_LOG=DEBUG terraform plan`
3. Check Azure portal for resource status
4. Review AKS diagnostics in Azure portal

## 📄 License

This project is provided as-is for educational and reference purposes.

---

**Happy Deploying! 🚀**
