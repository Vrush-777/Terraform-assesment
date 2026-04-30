# This module sets up the virtual network, subnets, and network security groups for the AKS cluster and ACR.
# VNet is a private network in Azure used to securely connect and isolate resources. It enables communication using private IPs, provides traffic control through subnets and security rules
resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.common_tags # assigning common tags to my azure resources, easy to manage
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = var.aks_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.aks_subnet_address_prefix

#we can allow this subnet to securely connect to specific azure services
  service_endpoints = [
    "Microsoft.ContainerRegistry",
    "Microsoft.Storage",
    "Microsoft.Sql",
    "Microsoft.KeyVault"
  ]
}

#configured for ACR, allowing secure communication between the AKS cluster and ACR without exposing traffic to the public internet.
resource "azurerm_subnet" "acr_subnet" {
  name                 = var.acr_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.acr_subnet_address_prefix

  service_endpoints = [
    "Microsoft.ContainerRegistry"
  ]
}

# it will control network traffic, Without NSG it will not secure
resource "azurerm_network_security_group" "aks_nsg" {
  name                = var.aks_nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name

#NSG can allow or deny traffic based on rules, define rules for inboud & outbound traffic, 
  security_rule {
    name                       = "AllowAKSNodePort"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "30000-32767"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.common_tags
}

resource "azurerm_subnet_network_security_group_association" "aks_subnet_nsg" {
  subnet_id                 = azurerm_subnet.aks_subnet.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}

resource "azurerm_network_security_group" "acr_nsg" {
  name                = var.acr_nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowACRPull"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = azurerm_subnet.aks_subnet.address_prefixes[0]
    destination_address_prefix = "*"
  }

  tags = var.common_tags
}

resource "azurerm_subnet_network_security_group_association" "acr_subnet_nsg" {
  subnet_id                 = azurerm_subnet.acr_subnet.id
  network_security_group_id = azurerm_network_security_group.acr_nsg.id
}

# User-Defined Routes for internal traffic
resource "azurerm_route_table" "aks_route_table" {
  name                = var.aks_route_table_name
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.common_tags
}

resource "azurerm_subnet_route_table_association" "aks_subnet_route" {
  subnet_id      = azurerm_subnet.aks_subnet.id
  route_table_id = azurerm_route_table.aks_route_table.id
}
