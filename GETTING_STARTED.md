# 🚀 Getting Started - First Time User Guide

Welcome to your production-ready Terraform + AKS Infrastructure project!

## 📋 What You Have

A complete, battle-tested infrastructure-as-code project that will deploy:
- **Azure Kubernetes Service (AKS)**: Managed Kubernetes cluster
- **Azure Container Registry (ACR)**: Private container image registry
- **Virtual Network**: Complete networking with subnets and security groups
- **Terraform State**: Remote, encrypted, versioned state file

## ⏱️ Time Required

- **First Time Setup**: 30 minutes
- **Subsequent Deployments**: 20 minutes
- **Cluster Ready**: 15-20 minutes after apply

## 🎯 Your First Deployment (Step-by-Step)

### Prerequisites Check (5 minutes)

```powershell
# 1. Check Terraform
terraform version
# Expected: Terraform v1.0 or higher

# 2. Check Azure CLI
az version
# Expected: version 2.40 or higher

# 3. Login to Azure
az login

# 4. Check subscription
az account show
```

### Backend Setup (5 minutes)

```powershell
# Create resource group for state
az group create `
  --name terraform-state-rg `
  --location eastus

# Create storage account (replace XXXX with random number)
$STORAGE_ACCOUNT = "tfstate$(Get-Random -Minimum 1000 -Maximum 9999)"
az storage account create `
  --name $STORAGE_ACCOUNT `
  --resource-group terraform-state-rg `
  --location eastus `
  --sku Standard_GRS `
  --encryption-services blob

# Get storage key
$STORAGE_KEY = az storage account keys list `
  --account-name $STORAGE_ACCOUNT `
  --resource-group terraform-state-rg `
  --query '[0].value' -o tsv

# Create blob container
az storage container create `
  --name terraform-state `
  --account-name $STORAGE_ACCOUNT `
  --account-key $STORAGE_KEY

# Save these for next step
Write-Host "Storage Account: $STORAGE_ACCOUNT"
Write-Host "Container: terraform-state"
```

### Terraform Initialization (5 minutes)

```powershell
# Navigate to project
cd c:\Users\vrushali.raskar\Terraform-assesment

# Initialize Terraform with backend
terraform init `
  -backend-config="resource_group_name=terraform-state-rg" `
  -backend-config="storage_account_name=$STORAGE_ACCOUNT" `
  -backend-config="container_name=terraform-state" `
  -backend-config="key=dev/terraform.tfstate"

# Verify
terraform validate
```

### Plan Deployment (5 minutes)

```powershell
# Generate deployment plan
terraform plan `
  -var-file=environments/dev.tfvars `
  -out=tfplan

# Review the output carefully
# Look for: AKS cluster, ACR, VNet, Subnets, etc.
```

### Apply Configuration (15-20 minutes)

```powershell
# Deploy infrastructure
terraform apply tfplan

# Wait for completion (you'll see green checkmarks)
```

### Access Your Cluster (5 minutes)

```powershell
# Get outputs
$RG_NAME = terraform output -raw resource_group_name
$CLUSTER_NAME = terraform output -raw aks_cluster_name

# Get kubeconfig
az aks get-credentials `
  --resource-group $RG_NAME `
  --name $CLUSTER_NAME

# Verify access
kubectl cluster-info
kubectl get nodes
kubectl get namespaces
```

## ✅ Verification Checklist

After deployment, verify everything worked:

```bash
# 1. Check cluster is running
kubectl get nodes
# Expected: 3 nodes in Ready state

# 2. Check system pods
kubectl get pods -n kube-system
# Expected: Multiple running pods

# 3. Check resource group
az group list --output table
# Expected: See your resource group

# 4. Check AKS cluster
az aks show -g $RG_NAME -n $CLUSTER_NAME
# Expected: Cluster status shows Succeeded

# 5. Check ACR
az acr list --output table
# Expected: See your container registry

# 6. Check storage account
az storage account list --output table
# Expected: See terraform-state account
```

## 🎓 Learn the Project Structure

### Root Files
- **terraform.tf**: Provider configuration
- **main.tf**: Main infrastructure (orchestrates modules)
- **variables.tf**: Input parameters (customize here)
- **outputs.tf**: Output values (reference these)
- **locals.tf**: Local values (naming conventions)

### Module Directories
```
modules/
├── resource_group/     → Azure Resource Group
├── network/            → VNet, Subnets, Security Groups
├── aks/                → Kubernetes Cluster & Nodes
├── acr/                → Container Registry
└── storage_account/    → Terraform State Storage
```

### Environment Configs
```
environments/
├── dev.tfvars          → Development settings (3 nodes)
└── prod.tfvars         → Production settings (5+ nodes)
```

## 🚀 Deploy Sample App

After cluster is running:

```powershell
# Create deployment
kubectl create deployment nginx --image=nginx

# Expose as service
kubectl expose deployment nginx `
  --type=LoadBalancer `
  --port=80 `
  --target-port=80

# Get public IP (wait ~2-3 minutes)
kubectl get services
# Note the EXTERNAL-IP

# Test in browser
# http://<EXTERNAL-IP>
```

## 🔧 Common Operations

### View Outputs
```bash
terraform output
```

### View Specific Output
```bash
terraform output aks_cluster_name
terraform output acr_login_server
terraform output aks_fqdn
```

### Check Current Configuration
```bash
terraform plan
```

### Destroy Everything (⚠️ careful!)
```bash
terraform destroy -var-file=environments/dev.tfvars
```

## 🐛 Troubleshooting

### "Insufficient permissions"
**Problem**: Can't create resources  
**Solution**: 
```bash
az account show
# Verify you have Owner or Contributor role
```

### "Storage account name not available"
**Problem**: Name already taken globally  
**Solution**: Use different random number:
```powershell
$STORAGE_ACCOUNT = "tfstate$(Get-Random -Minimum 100000 -Maximum 999999)"
```

### "Cluster not ready"
**Problem**: Nodes stuck "NotReady"  
**Solution**:
```bash
# Check node status
kubectl describe node <node-name>

# Check events
kubectl get events -A --sort-by='.lastTimestamp'
```

### "Cannot access kubeconfig"
**Problem**: No kubeconfig  
**Solution**:
```bash
az aks get-credentials -g <rg> -n <cluster-name>
```

## 📚 Next Learning Steps

1. **Read QUICKSTART.md** (5 min overview)
2. **Read README.md** (comprehensive guide)
3. **Read ARCHITECTURE.md** (design details)
4. **Explore module READMEs** (specific components)
5. **Customize variables.tf** (for your needs)
6. **Deploy to production** (prod.tfvars)

## 💡 Pro Tips

### Tip 1: Always Plan First
```bash
terraform plan -var-file=environments/dev.tfvars -out=tfplan
# Review output before applying
```

### Tip 2: Use Workspaces
```bash
terraform workspace new dev
terraform workspace new prod
terraform workspace select dev
```

### Tip 3: Save Kubeconfig
```bash
# Get kubeconfig to file
$KUBECONFIG = terraform output -raw aks_kube_config | Out-File kubeconfig.yaml
```

### Tip 4: Monitor Costs
```bash
# Check resource group costs
az cost management query --timeframe MonthToDate \
  --scope /subscriptions/<sub-id>/resourceGroups/<rg>
```

### Tip 5: Enable Logging
```bash
# For debugging
$env:TF_LOG="DEBUG"
terraform plan
$env:TF_LOG=""
```

## 🔐 Security Reminders

⚠️ **Important Security Notes:**

1. **Never commit .tfstate files** to Git
2. **Never commit *.tfvars** with secrets
3. **Use .gitignore** (included in project)
4. **Rotate credentials** regularly
5. **Use managed identities** (already configured)
6. **Enable monitoring** (optional but recommended)
7. **Audit access** (enable Azure logging)

## 📞 Get Help

**Quick Reference:**
- `terraform validate` → Check syntax
- `terraform fmt -recursive` → Format code
- `terraform state list` → List resources
- `terraform state show <resource>` → Show details
- `az aks show -g <rg> -n <cluster>` → Cluster info

**When Stuck:**
1. Check DEPLOYMENT_GUIDE.txt for commands
2. Read relevant module README
3. Check Terraform/Azure documentation
4. Enable TF_LOG=DEBUG for verbose output

## 🎯 Success Criteria

Your deployment is successful when:

✅ All Terraform resources created  
✅ Resource group visible in Azure Portal  
✅ AKS cluster status is "Succeeded"  
✅ Nodes are in "Ready" state  
✅ System pods are running  
✅ kubectl commands work  
✅ ACR accessible from cluster  
✅ Sample app deployable  

## 🚦 Next Steps After First Deploy

1. **Configure Monitoring**
   - Enable Log Analytics (optional)
   - Set up Azure Monitor alerts

2. **Setup CI/CD**
   - Connect GitHub/Azure DevOps
   - Create pipeline for image builds

3. **Deploy Applications**
   - Create namespaces
   - Deploy your apps
   - Configure ingress

4. **Security Hardening**
   - Enable pod security policies
   - Configure network policies
   - Setup RBAC roles

5. **Backup & Disaster Recovery**
   - Setup cluster backup
   - Document recovery procedures
   - Test failover scenarios

## 🎓 Learning Resources

- [Terraform Docs](https://www.terraform.io/docs)
- [AKS Documentation](https://learn.microsoft.com/en-us/azure/aks/)
- [Azure CLI Reference](https://learn.microsoft.com/en-us/cli/azure/)
- [Kubernetes Docs](https://kubernetes.io/docs/)

---

## ✨ You're Ready!

You now have:
- ✅ Production-ready infrastructure
- ✅ Complete documentation
- ✅ Reusable modules
- ✅ Environment support
- ✅ Security built-in
- ✅ Everything to deploy successfully

**Start here**: Follow the "Your First Deployment" section above.

**Questions?** Check the troubleshooting section or refer to detailed documentation.

---

**Estimated Time to First Deployment: 30 minutes**

**Happy deploying! 🚀**
