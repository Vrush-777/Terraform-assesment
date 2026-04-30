# ACR Module Details

## Overview
The ACR module creates a production-ready Azure Container Registry with private endpoints, encryption, and secure access controls.

## Architecture

```
┌─────────────────────────────────────────────┐
│   Azure Container Registry (ACR)            │
│                                             │
│  ┌────────────────────────────────────────┐│
│  │  Container Images                      ││
│  │  • myapp:v1.0                          ││
│  │  • myapp:v1.1                          ││
│  │  • myapp:latest                        ││
│  │  • otherapp:v2.0                       ││
│  └────────────────────────────────────────┘│
│                                             │
│  ┌────────────────────────────────────────┐│
│  │  Security & Access                     ││
│  │  • Private Endpoint                    ││
│  │  • Managed Identity                    ││
│  │  • RBAC (AcrPull, AcrPush)             ││
│  │  • Encryption                          ││
│  └────────────────────────────────────────┘│
└─────────────────────────────────────────────┘
         ↑                        ↑
         │                        │
      ┌──┴──────┐          ┌──────┴──┐
      │ AKS     │          │ Devops  │
      │ (Pull)  │          │ (Push)  │
      └─────────┘          └─────────┘
```

## Key Resources

### 1. Container Registry
```hcl
azurerm_container_registry "acr"
```

**Configuration:**
- **SKU Options**: Basic, Standard, Premium
- **Admin User**: Disabled (use Managed Identity)
- **Public Access**: Disabled by default
- **Encryption**: Enabled (with CMK support)
- **Data Endpoints**: Enabled for reliability

### 2. Private Endpoint
```hcl
azurerm_private_endpoint "acr_private_endpoint"
```

**Purpose:**
- Private connectivity to ACR
- No internet exposure
- VNet integration
- DNS resolution via Private DNS Zone

### 3. Private DNS Zone
```hcl
azurerm_private_dns_zone "acr_dns_zone"
```

**Configuration:**
- **Zone**: privatelink.azurecr.io
- **Records**: Auto-created for ACR
- **VNet Link**: Links to cluster VNet

### 4. Role Assignments
```hcl
azurerm_role_assignment "aks_acr_pull"
```

**Roles:**
- **AcrPull**: Read/pull images
- **AcrPush**: Write/push images
- **Owner**: Full access (not recommended)

## Configuration Examples

### Basic Configuration
```hcl
module "acr" {
  source = "./modules/acr"

  acr_name            = "myacr"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.rg.name
  
  sku = "Standard"
  enable_public_access = false
}
```

### Production Configuration with Private Endpoint
```hcl
module "acr" {
  source = "./modules/acr"

  acr_name            = "prodacr"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.rg.name
  
  sku = "Premium"
  
  # Private Endpoint
  subnet_id                       = azurerm_subnet.acr.id
  vnet_id                         = azurerm_virtual_network.vnet.id
  enable_private_endpoint         = true
  enable_private_dns_zone         = true
  
  # Security
  enable_public_access            = false
  enable_encryption               = true
  key_vault_key_id                = azurerm_key_vault_key.acr.id
  
  # AKS Integration
  enable_aks_integration          = true
  aks_principal_id                = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  
  common_tags = {
    Environment = "production"
  }
}
```

## SKU Comparison

| Feature | Basic | Standard | Premium |
|---------|-------|----------|---------|
| Storage | 10 GB | 100 GB | Unlimited |
| Throughput | Low | Medium | High |
| Webhooks | 2 | 10 | 500 |
| Geo-replication | No | No | Yes |
| Private Endpoint | No | No | Yes |
| VNet Access | No | No | Yes |
| Cost/Month | ~$5 | ~$20 | ~$50 |

**Recommendation**: Use **Premium** for production with AKS

## Security Features

### 1. Private Endpoints
```hcl
enable_private_endpoint = true
subnet_id               = azurerm_subnet.acr.id
```
- No public internet access
- Private IP in VNet
- DNS resolution via Private DNS

### 2. Managed Identity Access
```bash
# Login with managed identity
az acr login --name <acr-name>

# No credentials required for AKS pods
```

### 3. RBAC
```bash
# Assign AcrPull role to AKS
az role assignment create \
  --role AcrPull \
  --assignee <aks-principal-id> \
  --scope <acr-id>
```

### 4. Encryption
```hcl
enable_encryption = true
key_vault_key_id  = azurerm_key_vault_key.acr.id
```
- Default: Microsoft-managed keys
- Optional: Customer-managed keys in Key Vault

### 5. Network Rules
```bash
# Allow specific VNets/Subnets
az acr network-rule add \
  --name <acr-name> \
  --subnet <subnet-id>

# Deny all public access
az acr update --name <acr-name> \
  --public-network-enabled false
```

## Usage Examples

### Push Image to ACR
```bash
# Login to ACR
az acr login --name <acr-name>

# Tag local image
docker tag myapp:latest <acr-name>.azurecr.io/myapp:latest

# Push to ACR
docker push <acr-name>.azurecr.io/myapp:latest

# List images
az acr repository list --name <acr-name>
```

### Pull Image from AKS
```bash
# Create deployment using ACR image
kubectl create deployment myapp \
  --image=<acr-name>.azurecr.io/myapp:latest

# Kubernetes automatically authenticates via managed identity
```

### Deploy from ACR via YAML
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: <acr-name>.azurecr.io/myapp:v1.0
        ports:
        - containerPort: 8080
```

## Outputs

```hcl
output.acr_id                           # Registry ID
output.acr_name                         # Registry name
output.acr_login_server                 # Login server URL
output.acr_admin_username               # Admin user (sensitive)
output.acr_admin_password               # Admin password (sensitive)
output.private_endpoint_id              # Private endpoint ID
output.private_dns_zone_id              # Private DNS zone ID
```

## Troubleshooting

### Issue: Cannot Push/Pull Images
```bash
# Check RBAC role assignment
az role assignment list --scope <acr-id>

# Verify managed identity
az aks show -g <rg> -n <cluster-name> \
  --query "identity.principalId" -o tsv

# Test ACR access
az acr login --name <acr-name>
```

### Issue: Private Endpoint Not Resolving
```bash
# Check DNS zone
az network private-dns record-set list \
  -g <rg> -z privatelink.azurecr.io

# Verify DNS resolution from pod
kubectl run -it --rm debug --image=nicolaka/netshoot /bin/bash
nslookup <acr-name>.azurecr.io
```

### Issue: Public Access Blocked
```bash
# If legitimate public access needed
az acr update --name <acr-name> \
  --public-network-enabled true

# Or add specific IP ranges
az acr network-rule add \
  --name <acr-name> \
  --ip-address <public-ip>/32
```

## Best Practices

1. **Use Premium SKU** for production
2. **Enable Private Endpoints** for security
3. **Disable Public Access** when possible
4. **Use Managed Identity** for AKS
5. **Enable Image Scanning** for vulnerabilities
6. **Retention Policies** to manage storage
7. **Geo-replication** for disaster recovery
8. **Webhook Integration** for CI/CD

## Advanced Scenarios

### Geo-Replication
```bash
az acr replication create \
  --registry <acr-name> \
  --location westus
```

### Image Retention Policy
```bash
az acr config retention update \
  --registry <acr-name> \
  --days 30 \
  --status enabled
```

### Webhook for CI/CD
```bash
az acr webhook create \
  --registry <acr-name> \
  --name mywebhook \
  --actions push \
  --uri https://myapp.example.com/webhook
```

---

For more information, see [main README.md](../README.md)
