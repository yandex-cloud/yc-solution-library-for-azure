
#-------------------------------
# Public ip address for VPN gateway in Azure
#-------------------------------

resource "azurerm_public_ip" "azure-vpn-ip" {
  name                = "${var.azure_vnet_name}-vpn-gw-pub-ip"
  resource_group_name = var.rgname
  location            = var.location
  allocation_method   = "Dynamic"
  tags = var.labels
  
}

data "azurerm_public_ip" "azure-vpn-ip" {
  name = azurerm_public_ip.azure-vpn-ip.name
  resource_group_name = var.rgname
}


#-------------------------------
# Gateway subnet for vpn-gateway to reside
#-------------------------------

resource "azurerm_subnet" "azure-gateway-subnet" {
  count = length(var.azure_gateway_subnet_range)
  name                 = "GatewaySubnet"
  resource_group_name = var.rgname
  virtual_network_name = var.azure_vnet_name
  address_prefixes     = [var.azure_gateway_subnet_range[count.index]]
}

#-------------------------------
# subnet for resources protected by vpn tunnel in azure
#-------------------------------
resource "azurerm_subnet" "azure-vpn-protected" {
  count = length(var.azure_subnet_range)
  name                = "${var.azure_vnet_name}-protected-subnet"
  resource_group_name = var.rgname
  virtual_network_name = var.azure_vnet_name
  address_prefixes     = [var.azure_subnet_range[count.index]]
}

#-------------------------------
# route table and route towards yandex subnet
#-------------------------------
resource "azurerm_route_table" "azure-rt" {
  name                = "${var.azure_vnet_name}-azure-rt"
  resource_group_name = var.rgname
  location = var.location
}

resource "azurerm_route" "azure-route" {
  name                = "${var.azure_vnet_name}-azure-route"
  resource_group_name = var.rgname
  route_table_name    = azurerm_route_table.azure-rt.name
  address_prefix      = var.yandex_subnet_range
  next_hop_type       = "VirtualNetworkGateway"
}
