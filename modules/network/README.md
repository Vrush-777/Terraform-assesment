# Network Module Details

## Overview
The network module creates and configures the Azure networking infrastructure required for AKS and ACR.

## Resources Created

### 1. Virtual Network
```hcl
azurerm_virtual_network "vnet"
```
- **CIDR**: 10.0.0.0/8 (configurable)
- **Purpose**: Main network for all services
- **Tags**: Applied from common_tags

### 2. Subnets

#### AKS Subnet
```hcl
azurerm_subnet "aks_subnet"
```
- **CIDR**: 10.0.0.0/16 (configurable)
- **Service Endpoints**: 
  - Microsoft.ContainerRegistry
  - Microsoft.Storage
  - Microsoft.Sql
  - Microsoft.KeyVault
- **Purpose**: Hosts AKS cluster nodes
- **Max Pods**: Up to 110 per node

#### ACR Subnet
```hcl
azurerm_subnet "acr_subnet"
```
- **CIDR**: 10.1.0.0/16 (configurable)
- **Service Endpoints**: 
  - Microsoft.ContainerRegistry
- **Purpose**: Hosts private endpoint for ACR
- **Access**: Restricted to AKS subnet

### 3. Network Security Groups (NSGs)

#### AKS NSG
- **Port 30000-32767**: Node Port Range (Kubernetes services)
- **Default**: Deny all inbound (except rules)
- **Outbound**: Allow all (configurable)

#### ACR NSG
- **Port 443**: HTTPS (container registry)
- **Source**: AKS Subnet only
- **Default**: Deny all other inbound

### 4. Route Tables
- **AKS Route Table**: For custom routing policies
- **Association**: AKS Subnet

## Network Topology

```
┌─────────────────────────────────────────────────────────┐
│                Virtual Network (10.0.0.0/8)             │
│                                                         │
│  ┌─────────────────────┐  ┌─────────────────────┐     │
│  │  AKS Subnet         │  │  ACR Subnet         │     │
│  │  (10.0.0.0/16)      │  │  (10.1.0.0/16)      │     │
│  │                     │  │                     │     │
│  │ ├─ Node Pool        │  │ ├─ Private Endpoint │     │
│  │ ├─ Load Balancer    │  │ ├─ Private DNS      │     │
│  │ └─ Service Pods     │  │ └─ Firewall Rules   │     │
│  │                     │  │                     │     │
│  │ NSG Rules:          │  │ NSG Rules:          │     │
│  │ • Port 30000-32767  │  │ • Port 443          │     │
│  │ • Allow internal    │  │ • From AKS Subnet   │     │
│  └─────────────────────┘  └─────────────────────┘     │
│          │                        │                    │
│          └────────────────────────┘                    │
│              (Peering/Routing)                         │
└─────────────────────────────────────────────────────────┘
```

## Security Features

### 1. Network Segmentation
- Separate subnets for AKS and ACR
- NSGs restricting traffic between subnets
- Service endpoints for Azure services

### 2. Access Control
- Default-deny inbound policy
- Explicit rules for required ports
- Source/destination restrictions

### 3. Private Connectivity
- Service endpoints for Azure services
- Private endpoints for ACR (optional)
- No public internet exposure required

## Configuration Examples

### Basic Configuration
```hcl
module "network" {
  source = "./modules/network"

  location            = "eastus"
  resource_group_name = azurerm_resource_group.rg.name
  
  virtual_network_name = "aks-vnet"
  address_space = ["10.0.0.0/8"]
  
  aks_subnet_name = "aks-subnet"
  aks_subnet_address_prefix = ["10.0.0.0/16"]
  
  acr_subnet_name = "acr-subnet"
  acr_subnet_address_prefix = ["10.1.0.0/16"]
}
```

### Advanced Configuration
```hcl
module "network" {
  source = "./modules/network"

  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  
  virtual_network_name = "prod-vnet"
  address_space = ["10.0.0.0/8"]
  
  aks_subnet_name = "prod-aks-subnet"
  aks_subnet_address_prefix = ["10.0.0.0/16"]
  
  acr_subnet_name = "prod-acr-subnet"
  acr_subnet_address_prefix = ["10.1.0.0/16"]
  
  aks_nsg_name = "prod-aks-nsg"
  acr_nsg_name = "prod-acr-nsg"
  aks_route_table_name = "prod-aks-rt"
  
  common_tags = {
    Environment = "production"
    Team = "platform"
  }
}
```

## Outputs

```hcl
# Virtual Network
output.virtual_network_id
output.virtual_network_name

# AKS Subnet
output.aks_subnet_id
output.aks_subnet_name

# ACR Subnet
output.acr_subnet_id
output.acr_subnet_name

# Network Security Groups
output.aks_nsg_id
output.acr_nsg_id
```

## Common Issues

### 1. CIDR Conflicts
**Problem**: Subnets have overlapping CIDR ranges
```
Error: overlapping subnets
```
**Solution**: Ensure CIDR ranges don't overlap
```hcl
aks_subnet_address_prefix = ["10.0.0.0/16"]    # OK
acr_subnet_address_prefix = ["10.1.0.0/16"]    # OK
```

### 2. Route Table Association
**Problem**: Routes not working as expected
**Solution**: Verify route table association and UDR rules
```bash
az network route-table show -g <rg> -n <rt-name>
az network route-table route list -g <rg> -t <rt-name>
```

### 3. NSG Rules Not Applied
**Problem**: Traffic still flowing when NSG denies it
**Solution**: Check NSG association and rule priorities
```bash
az network nsg rule list -g <rg> --nsg-name <nsg-name>
```

## Best Practices

1. **Use /16 for Subnets**: Allows up to 65,000+ IPs per subnet
2. **Separate Concerns**: Different subnets for different workloads
3. **Document CIDR Ranges**: Keep track of all ranges
4. **Apply NSG Rules**: Implement least-privilege access
5. **Monitor Traffic**: Enable NSG flow logs
6. **Regular Review**: Audit rules quarterly

## Testing Connectivity

### From AKS to ACR
```bash
# SSH into AKS node
kubectl debug node/<node-name> -it --image=ubuntu

# Test ACR connectivity
curl -v https://<acr-name>.azurecr.io
```

### Verify Service Endpoints
```bash
az network vnet subnet list -g <rg> --vnet-name <vnet> --query [].serviceEndpoints
```

---

For more information, see [main README.md](../README.md)
