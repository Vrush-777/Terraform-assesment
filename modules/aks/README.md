# AKS Module Details

## Overview
The AKS module creates and configures a production-ready Azure Kubernetes Service cluster with security, scalability, and monitoring built-in.

## Architecture

```
┌────────────────────────────────────────────────┐
│         Azure Kubernetes Service              │
│                                                │
│  ┌──────────────────────────────────────────┐ │
│  │  System Components                       │ │
│  │  • API Server                            │ │
│  │  • Controller Manager                    │ │
│  │  • Scheduler                             │ │
│  │  • etcd                                  │ │
│  └──────────────────────────────────────────┘ │
│                                                │
│  ┌──────────────────────────────────────────┐ │
│  │  Default Node Pool                       │ │
│  │  (Configurable nodes)                    │ │
│  │                                          │ │
│  │  Node 1   Node 2   Node 3  ...          │ │
│  │  ┌────┐  ┌────┐  ┌────┐                │ │
│  │  │Pod │  │Pod │  │Pod │                │ │
│  │  │Pod │  │Pod │  │Pod │                │ │
│  │  └────┘  └────┘  └────┘                │ │
│  └──────────────────────────────────────────┘ │
│                                                │
│  ┌──────────────────────────────────────────┐ │
│  │  Additional Node Pools (Optional)        │ │
│  │  • Workload pool                         │ │
│  │  • System pool                           │ │
│  └──────────────────────────────────────────┘ │
└────────────────────────────────────────────────┘
```

## Key Resources

### 1. AKS Cluster
```hcl
azurerm_kubernetes_cluster "aks"
```

**Configuration:**
- **Network**: Azure CNI with configurable CIDR ranges
- **Identity**: System-assigned managed identity
- **RBAC**: Azure RBAC + Kubernetes RBAC (via AAD)
- **Monitoring**: Container Insights (optional)
- **Policy**: Azure Policy addon
- **API Access**: Private API server (optional)

### 2. Node Pools

#### Default Node Pool
- **Auto-scaling**: Supported (configure min/max)
- **Availability Zones**: Multi-AZ for HA
- **Taints/Labels**: Customizable
- **VM Sizing**: Configurable

#### Additional Node Pools
- **Workload Pools**: For specific workloads
- **System Pools**: Dedicated for system components
- **GPU Pools**: For ML workloads

### 3. Managed Identities

#### Cluster Identity
- **Type**: System-assigned
- **Permissions**: Network Contributor on subnet
- **Purpose**: Cluster management

#### Kubelet Identity
- **Type**: User-assigned
- **Permissions**: Network Contributor on subnet
- **Purpose**: Node operations

## Configuration Examples

### Minimal Configuration
```hcl
module "aks" {
  source = "./modules/aks"

  aks_cluster_name    = "prod-aks"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "prod-aks"
  subnet_id           = azurerm_subnet.aks.id
  
  node_count = 3
  vm_size    = "Standard_D2s_v3"
}
```

### Production Configuration
```hcl
module "aks" {
  source = "./modules/aks"

  aks_cluster_name    = "prod-aks"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "prod-aks"
  subnet_id           = azurerm_subnet.aks.id
  
  # Cluster settings
  kubernetes_version  = "1.27"
  node_count          = 5
  vm_size             = "Standard_D4s_v3"
  max_pods            = 110
  availability_zones  = ["1", "2", "3"]
  
  # Networking
  network_plugin      = "azure"
  network_policy      = "azure"
  service_cidr        = "10.0.0.0/16"
  dns_service_ip      = "10.0.0.10"
  docker_bridge_cidr  = "172.17.0.1/16"
  
  # Security
  admin_group_object_ids = ["<AAD-GROUP-ID>"]
  authorized_ip_ranges   = ["<YOUR-IP>/32"]
  enable_azure_policy    = true
  
  # Monitoring
  log_analytics_workspace_id = "/subscriptions/.../workspaces/..."
  
  # Additional pools
  create_additional_node_pool = true
  additional_node_pool_name   = "workload"
  additional_node_count       = 3
  additional_vm_size          = "Standard_D4s_v3"
  
  common_tags = {
    Environment = "production"
    Team        = "platform"
  }
}
```

## Security Features

### 1. RBAC
- **Type**: Azure RBAC (recommended) + Kubernetes RBAC
- **Admin Access**: AAD Group-based
- **Service Accounts**: Managed by Kubernetes

### 2. Network Security
- **Network Policy**: Azure Network Policy enforcement
- **Service Endpoints**: Configured for Azure services
- **Private API Server**: Optional API endpoint restriction

### 3. Managed Identities
- **Cluster Identity**: For infrastructure operations
- **Kubelet Identity**: For node operations
- **No Service Principals**: Modern, secure approach

### 4. Policies
- **Azure Policy**: Built-in compliance
- **Pod Security**: Via Azure Policy
- **Network Policies**: Inter-pod communication control

## Outputs

```hcl
# Cluster Info
output.aks_cluster_id
output.aks_cluster_name
output.aks_fqdn

# Access
output.aks_kube_config              # Sensitive
output.aks_client_certificate       # Sensitive
output.aks_client_key               # Sensitive
output.aks_cluster_ca_certificate   # Sensitive

# Identities
output.aks_principal_id
output.kubelet_identity_id
output.kubelet_identity_principal_id

# Addons
output.aks_http_application_routing_zone_name
```

## Post-Deployment Setup

### 1. Get Credentials
```bash
az aks get-credentials -g <rg> -n <cluster-name>
```

### 2. Verify Cluster
```bash
kubectl cluster-info
kubectl get nodes
kubectl get namespaces
```

### 3. Deploy Sample App
```bash
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --type=LoadBalancer --port=80
kubectl get services
```

### 4. Check Cluster Addons
```bash
az aks show -g <rg> -n <cluster-name> --query addonProfiles
```

## Scaling and Operations

### Add Node Pool
```bash
terraform apply -var="create_additional_node_pool=true"
```

### Scale Default Pool
```bash
# Manual scaling
az aks scale -g <rg> -n <cluster-name> -c <node-count>

# Or update variable and apply
terraform apply -var="node_count=10"
```

### Update Kubernetes Version
```bash
terraform apply -var="kubernetes_version=1.28"
```

### Add Node Labels
```hcl
additional_node_labels = {
  "workload-type"   = "gpu"
  "environment"     = "production"
}
```

## Troubleshooting

### Issue: Nodes Not Ready
```bash
# Check node status
kubectl describe node <node-name>

# Check kubelet logs
kubectl logs -n kube-system <kubelet-pod-name>

# Check system pods
kubectl get pods -n kube-system
```

### Issue: Pod Cannot Pull Image
```bash
# Check ACR permissions
az role assignment list --scope <acr-id>

# Test ACR access
az acr login --name <acr-name>
```

### Issue: API Server Unreachable
```bash
# Check API server status
az aks show -g <rg> -n <cluster-name> --query apiServerAccessProfile

# Verify IP whitelisting if enabled
```

### Issue: Pod Networking Issues
```bash
# Check network policy
kubectl get networkpolicies -A

# Verify pod IP assignment
kubectl get pods -o wide

# Test connectivity
kubectl exec -it <pod-name> -- ping <other-pod-ip>
```

## Performance Tuning

### 1. Pod Density
- **Max Pods**: Default 110 per node
- **Adjust**: `max_pods = 250` for higher density
- **Trade-off**: IP address availability

### 2. Node Sizing
- **Dev**: Standard_D2s_v3 (2 vCPU, 8GB RAM)
- **Prod**: Standard_D4s_v3 (4 vCPU, 16GB RAM)
- **Large**: Standard_D8s_v3 (8 vCPU, 32GB RAM)

### 3. Availability Zones
- **Default**: Zones 1, 2, 3 (multi-AZ)
- **Benefits**: High availability and fault tolerance
- **Cost**: Slight increase for cross-zone traffic

## Cost Optimization

### 1. Right-sizing
```hcl
# Dev/Test
vm_size = "Standard_B4ms"      # Lower cost

# Production
vm_size = "Standard_D4s_v3"    # Balanced
```

### 2. Autoscaling
```hcl
# Configure in Azure Portal or via CLI
az aks nodepool update \
  -g <rg> \
  --cluster-name <cluster> \
  -n <pool-name> \
  --enable-cluster-autoscaler \
  --min-count 1 \
  --max-count 10
```

### 3. Spot Instances
```bash
# Use for non-critical workloads
az aks nodepool add \
  -g <rg> \
  --cluster-name <cluster> \
  -n spot-pool \
  --priority Spot \
  --spot-max-price 0.5
```

## Best Practices

1. **Always use Azure CNI** for production
2. **Enable RBAC** with AAD groups
3. **Use Network Policies** for security
4. **Monitor with Log Analytics** for insights
5. **Regular Updates**: Keep Kubernetes version current
6. **Node Maintenance**: Use Azure maintenance windows
7. **Pod Disruption Budgets**: Define for critical apps
8. **Resource Requests/Limits**: Always set for pods

---

For more information, see [main README.md](../README.md)
