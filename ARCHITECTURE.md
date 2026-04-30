# Architecture and Design Documentation

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Azure Subscription                          │
│                                                                     │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │                   Resource Group                             │ │
│  │  (aks-platform-dev-rg)                                       │ │
│  │                                                              │ │
│  │  ┌─────────────────────────────────────────────────────────┐│ │
│  │  │              Virtual Network (10.0.0.0/8)               ││ │
│  │  │                                                         ││ │
│  │  │  ┌──────────────────┐    ┌──────────────────┐         ││ │
│  │  │  │ AKS Subnet       │    │ ACR Subnet       │         ││ │
│  │  │  │ (10.0.0.0/16)    │    │ ([REDACTED_IPV4_ADDRESS_1]/16)   │         ││ │
│  │  │  │                  │    │                  │         ││ │
│  │  │  │  ┌────────────┐  │    │  ┌────────────┐ │         ││ │
│  │  │  │  │   AKS      │  │    │  │  Private   │ │         ││ │
│  │  │  │  │  Cluster   │  │    │  │ Endpoint   │ │         ││ │
│  │  │  │  │            │  │    │  │            │ │         ││ │
│  │  │  │  │ • Nodes    │  │    │  │ • ACR      │ │         ││ │
│  │  │  │  │ • Pods     │  │    │  │ • DNS Zone │ │         ││ │
│  │  │  │  │ • Services │  │    │  │            │ │         ││ │
│  │  │  │  └────────────┘  │    │  └────────────┘ │         ││ │
│  │  │  │                  │    │                  │         ││ │
│  │  │  │  NSG Rules:      │    │  NSG Rules:      │         ││ │
│  │  │  │  • 30000-32767   │    │  • 443 (HTTPS)   │         ││ │
│  │  │  └──────────────────┘    └──────────────────┘         ││ │
│  │  │         ↓                        ↓                    ││ │
│  │  │    [Traffic]────────────[Traffic]                    ││ │
│  │  └─────────────────────────────────────────────────────────┘│ │
│  │                                                              │ │
│  │  ┌──────────────────────────────────────────────────────┐   │ │
│  │  │   Container Registry (ACR)                          │   │ │
│  │  │   • Images stored and managed                       │   │ │
│  │  │   • Encryption enabled                             │   │ │
│  │  │   • RBAC enforced                                  │   │ │
│  │  └──────────────────────────────────────────────────────┘   │ │
│  │                                                              │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
         ↑                                          ↑
         │                                          │
    ┌────┴───────────────┐             ┌──────────┴────┐
    │   Azure Storage    │             │  Log Analytics│
    │   (State File)     │             │  (Monitoring) │
    │                    │             │               │
    │ • terraform.state  │             │ • Cluster     │
    │ • Versioning      │             │ • Container   │
    │ • Backup          │             │ • Performance │
    └────────────────────┘             └───────────────┘
```

## Data Flow Diagram

```
Developer/CI/CD
      ↓
      └─→ Docker Build
           ↓
      Push to ACR
           ↓
      ┌─────────────────────────────────────────┐
      │  Azure Container Registry (Private)      │
      │  (Authentication via Managed Identity)   │
      └──────────────────┬──────────────────────┘
                        ↓
      ┌─────────────────────────────────────────┐
      │  AKS Cluster (kubelet)                  │
      │  ├─ Authenticate via Managed Identity   │
      │  ├─ Pull image from ACR                 │
      │  └─ Deploy pod with image               │
      └──────────────────┬──────────────────────┘
                        ↓
      ┌─────────────────────────────────────────┐
      │  Running Workload                       │
      │  ├─ Service traffic                     │
      │  ├─ Logs → Log Analytics                │
      │  └─ Metrics → Azure Monitor             │
      └─────────────────────────────────────────┘
```

## Deployment Components

### 1. Infrastructure Layer

#### Resource Group
- **Purpose**: Container for all resources
- **Naming**: `{project}-{environment}-rg`
- **Scope**: Single Azure subscription

#### Virtual Network
- **CIDR**: 10.0.0.0/8 (extremely large for future growth)
- **Subnets**: Separated by function
- **Service Endpoints**: Azure service connectivity

#### Subnets
- **AKS Subnet**: Contains Kubernetes nodes
- **ACR Subnet**: Contains private endpoint

### 2. Container Orchestration

#### AKS Cluster
- **Version**: Configurable (default: latest stable)
- **Networking**: Azure CNI for advanced networking
- **Node Pools**: Multiple pools for different workloads
- **Monitoring**: Optional Log Analytics integration

#### Node Configuration
- **SKU Options**: 
  - Dev: Standard_D2s_v3 (2 vCPU, 8 GB RAM)
  - Prod: Standard_D4s_v3 (4 vCPU, 16 GB RAM)
- **Availability Zones**: Multi-AZ for HA
- **Auto-scaling**: Supported via configuration

### 3. Container Registry

#### ACR Setup
- **SKU**: Premium (production recommended)
- **Access**: Private endpoint only
- **Authentication**: Managed identity
- **Encryption**: Enabled with optional CMK

### 4. State Management

#### Terraform State Storage
- **Location**: Azure Blob Storage
- **Replication**: GRS (Geo-Redundant)
- **Protection**: Versioning + Deletion lock
- **Access**: Private (no public access)

## Security Architecture

### Authentication & Authorization

```
┌─────────────────────────────────────────┐
│     Azure Active Directory               │
│                                         │
│  ├─ Cluster Admin Group                │
│  ├─ Application Identities             │
│  └─ User Identities                    │
│                                         │
└──────────────┬──────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│     AKS RBAC                             │
│                                         │
│  ├─ Azure RBAC (Management Plane)      │
│  │  • Cluster Admin                     │
│  │  • Network Contributor               │
│  │                                      │
│  ├─ Kubernetes RBAC (Data Plane)       │
│  │  • ClusterRole / ClusterRoleBinding │
│  │  • Role / RoleBinding                │
│  │                                      │
│  └─ Pod Identity / Workload Identity   │
│     • For pod-to-service auth          │
│                                         │
└─────────────────────────────────────────┘
```

### Network Security

```
Inbound Traffic Flow:
┌──────────────────────────────────┐
│  Internet / External Network     │
└────────────────┬─────────────────┘
                 ↓
┌──────────────────────────────────┐
│  Azure Firewall / NSG            │
│  (Ingress Rules)                 │
└────────────────┬─────────────────┘
                 ↓
┌──────────────────────────────────┐
│  VNet / Subnet NSGs              │
│  • AKS NSG: Port 30000-32767     │
│  • ACR NSG: Port 443             │
└────────────────┬─────────────────┘
                 ↓
┌──────────────────────────────────┐
│  Service Endpoints / Network Pol │
│  • Pod-to-pod communication      │
│  • Service access                │
└──────────────────────────────────┘
```

## Identity & Access Management

### Managed Identities

```
AKS Cluster
├─ System-Assigned Identity
│  └─ Permissions: Network Contributor on subnet
│
└─ Kubelet User-Assigned Identity
   └─ Permissions: Network Contributor on subnet

ACR Access
└─ AKS uses Kubelet Identity → AcrPull role
   └─ Enables: Pull images without credentials
```

## High Availability Design

### Multi-Zone Deployment
```
Zone 1          Zone 2          Zone 3
├─ Node Pool    ├─ Node Pool    ├─ Node Pool
│  ├─ Pod       │  ├─ Pod       │  ├─ Pod
│  ├─ Pod       │  ├─ Pod       │  ├─ Pod
│  └─ Pod       │  └─ Pod       │  └─ Pod
└─ API Server   └─ API Server   └─ API Server
```

### Features
- **Data Redundancy**: Across zones
- **Service Availability**: Multi-AZ coverage
- **Fault Tolerance**: Node failure handling
- **Automatic Failover**: Built-in

## Scalability Strategy

### Horizontal Scaling
```
Phase 1: 3 nodes (initial)
Phase 2: 5 nodes (growth)
Phase 3: 10+ nodes (large workload)

Via: Kubernetes Autoscaler or manual scaling
```

### Vertical Scaling
```
VM Sizes (in order of capacity):
1. Standard_D2s_v3 (dev)
2. Standard_D4s_v3 (prod)
3. Standard_D8s_v3 (large)
4. Standard_D16s_v3 (xlarge)

Change: Update vm_size variable
```

## Monitoring & Observability

### Metrics Collection
```
AKS Cluster
    ↓
Container Insights / Log Analytics
    ↓
├─ Cluster metrics
├─ Node metrics
├─ Pod metrics
├─ Container metrics
└─ Application logs

Azure Monitor Dashboard
    ↓
├─ Real-time visualization
├─ Alerts
└─ Custom dashboards
```

### Key Metrics
- CPU utilization
- Memory usage
- Network I/O
- Disk I/O
- Pod count
- Node status
- Image pulls

## Deployment Stages

### Stage 1: Planning
1. Define infrastructure requirements
2. Plan network topology
3. Size compute resources
4. Design for HA/DR

### Stage 2: Setup Backend
1. Create storage account
2. Initialize Terraform
3. Validate configuration

### Stage 3: Deploy Infrastructure
1. Apply Terraform
2. Verify resource creation
3. Obtain cluster credentials

### Stage 4: Post-Deployment
1. Deploy sample workload
2. Configure monitoring
3. Set up CI/CD
4. Document access procedures

## Cost Optimization Strategies

### Infrastructure Costs
| Component | Cost | Optimization |
|-----------|------|--------------|
| AKS Nodes | Largest | Use Spot instances, Autoscaling |
| ACR Premium | ~$50/mo | Use Standard for dev |
| Storage | Minimal | Use LRS for state file |
| Bandwidth | Variable | Minimize inter-region traffic |

### Best Practices
1. **Dev**: Minimal nodes (1-3), B/D2 SKUs
2. **Prod**: Adequate nodes (5+), D4+ SKUs
3. **Auto-scaling**: Enable for variable workloads
4. **Reserved Instances**: For stable baseline
5. **Spot Instances**: For batch/non-critical

## Disaster Recovery

### Backup Strategy
```
Terraform State
├─ Remote storage (GRS)
├─ Versioning enabled
├─ Deletion lock applied
└─ Regular manual backups

AKS Cluster
├─ Node availability across zones
├─ Pod replicas across nodes
├─ Persistent data in Azure Disk/File
└─ Regular cluster snapshots (optional)

Container Images
└─ Geo-replicated ACR (Premium)
```

### Recovery Procedures
1. **Node Failure**: Auto-replace via Kubernetes
2. **Cluster Failure**: Redeploy via Terraform
3. **State Corruption**: Recover from previous version
4. **Image Loss**: Restore from geo-replicated ACR

## Network Design Decisions

### Why Azure CNI?
- Better IP management
- Direct pod IPs in VNet
- Easier integration with Azure services
- Better performance

### Why Private Endpoint for ACR?
- No public internet exposure
- Private connectivity via VNet
- Security best practice
- Compliance requirement support

### Why Multiple Subnets?
- Network segmentation
- Different security policies
- Resource organization
- Future expansion flexibility

## Operational Procedures

### Adding New Node Pool
```hcl
create_additional_node_pool = true
additional_node_pool_name   = "workload"
additional_node_count       = 2
```

### Updating Kubernetes Version
```hcl
kubernetes_version = "1.28"
```
Then: `terraform apply`

### Scaling Cluster
```bash
# Via terraform
terraform apply -var="node_count=10"

# Or via Azure CLI
az aks scale -g <rg> -n <cluster> -c 10
```

---

**This architecture provides:**
- ✅ Production-grade security
- ✅ High availability across zones
- ✅ Scalability for growth
- ✅ Cost optimization options
- ✅ Disaster recovery capabilities
- ✅ Full infrastructure as code

For detailed implementation, see [README.md](README.md)
