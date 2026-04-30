# Terraform AKS Infrastructure - Quick Start Guide

## 📋 Prerequisites

```bash
# 1. Verify Terraform installation
terraform version

# 2. Verify Azure CLI
az version

# 3. Verify kubectl (optional, for cluster testing)
kubectl version --client

# 4. Login to Azure
az login
az account list --output table
az account set --subscription "<SUBSCRIPTION_ID>"
```

## 🚀 Quick Start (5 Minutes)

### Step 1: Create Backend Storage
```bash
# Create resource group
az group create -n terraform-state-rg -l eastus

# Create storage account
az storage account create \
  -n tfstate$(date +%s) \
  -g terraform-state-rg \
  -l eastus \
  --sku Standard_GRS

# Create container
az storage container create \
  -n terraform-state \
  --account-name <STORAGE_ACCOUNT_NAME>
```

### Step 2: Initialize Terraform
```bash
cd Terraform-assesment

terraform init \
  -backend-config="resource_group_name=terraform-state-rg" \
  -backend-config="storage_account_name=<STORAGE_ACCOUNT_NAME>" \
  -backend-config="container_name=terraform-state" \
  -backend-config="key=dev/terraform.tfstate"
```

### Step 3: Plan & Apply
```bash
# Validate
terraform validate

# Plan deployment
terraform plan -var-file=environments/dev.tfvars -out=tfplan

# Apply (this will take ~10-15 minutes)
terraform apply tfplan
```

### Step 4: Access Cluster
```bash
# Get credentials
az aks get-credentials \
  -g $(terraform output -raw resource_group_name) \
  -n $(terraform output -raw aks_cluster_name)

# Verify access
kubectl get nodes
```

## 📊 Deployment Timeline

| Phase | Duration | Task |
|-------|----------|------|
| Storage Setup | 2 min | Create backend storage |
| Terraform Init | 1 min | Initialize Terraform |
| Resource Group | <1 min | Create RG |
| Network | 2-3 min | Create VNet, Subnets, NSGs |
| ACR | 3-5 min | Create container registry |
| AKS | 5-10 min | Provision cluster |
| Post-Deploy | 1 min | Get credentials |
| **Total** | **15-22 min** | Full deployment |

## 🔧 Useful Commands

```bash
# View outputs
terraform output

# State management
terraform state list
terraform state show 'module.aks.azurerm_kubernetes_cluster.aks'

# Destroy (if needed)
terraform destroy -var-file=environments/dev.tfvars

# Get kubeconfig
terraform output -raw aks_kube_config > kubeconfig.yaml
export KUBECONFIG=kubeconfig.yaml
```

## 🔒 Important Security Notes

1. **State File**: Stored remotely in Azure Storage (encrypted)
2. **Credentials**: Never commit `*.tfstate` to Git
3. **Access**: Use Azure RBAC and Managed Identities
4. **Network**: ACR uses private endpoints by default

## ⚠️ Costs

**Estimated Monthly Costs (Dev Environment):**
- AKS (3 nodes, D2s_v3): ~$180
- ACR (Premium): ~$50
- Network: ~$20
- Storage (state file): <$1
- **Total: ~$250/month**

Reduce costs by:
- Using Standard D2s_v3 for dev
- Using Standard ACR SKU instead of Premium
- Enabling autoscaling with lower limits

## 🐛 Common Issues

| Issue | Solution |
|-------|----------|
| "Storage account name not available" | Use unique name with random suffix |
| "Insufficient quota" | Check Azure quotas or request increase |
| "CIDR conflict" | Modify address_space in tfvars |
| "Authentication failed" | Run `az login` again |
| "Subnet too small" | Use /16 for subnets instead of /24 |

## 📚 Next Steps

After deployment:

1. **Deploy Sample App**
   ```bash
   kubectl create deployment nginx --image=nginx
   kubectl expose deployment nginx --type=LoadBalancer --port=80
   ```

2. **Push Image to ACR**
   ```bash
   az acr login --name $(terraform output -raw acr_name)
   docker tag myimage:latest $(terraform output -raw acr_login_server)/myimage:latest
   docker push $(terraform output -raw acr_login_server)/myimage:latest
   ```

3. **Configure Monitoring**
   - Enable Log Analytics in Azure Portal
   - Set `log_analytics_workspace_id` variable

4. **Add Network Policies**
   - Use Azure Network Policies addon
   - Define ingress/egress rules

## 📖 Documentation

- [README.md](./README.md) - Full documentation
- [Terraform Variables](./variables.tf) - All configurable options
- [Module Details](./modules/) - Individual module documentation
- [Environment Files](./environments/) - Configuration examples

---

**✅ You're ready to deploy! Start with Step 1: Create Backend Storage**
