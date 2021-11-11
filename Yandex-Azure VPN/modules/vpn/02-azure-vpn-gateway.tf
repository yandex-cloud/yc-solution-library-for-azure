

#-------------------------------
# Vpn-gateway for S2S tunnel
#-------------------------------
resource "azurerm_virtual_network_gateway" "azure-vpn-gw" {
  name                = "${var.azure_vnet_name}-vpn-gw"
  resource_group_name = var.rgname
  location            = var.location

  type     = "Vpn"
  vpn_type = "RouteBased"
  generation = "Generation2"
  active_active = false
  enable_bgp    = false
  sku           = "VpnGw2"
  tags = var.labels
  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.azure-vpn-ip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.azure-gateway-subnet.0.id
  }

}

#---------------------------
# Local Network Gateway which represents remote endpoint at Yandex
#---------------------------
resource "azurerm_local_network_gateway" "localgw" {
  name                = "${var.azure_vnet_name}-yandex-local-gw"
  resource_group_name = var.rgname
  location            = var.location
  gateway_address     = data.yandex_vpc_address.vpn_address.external_ipv4_address.0.address
  address_space       = split(",", var.yandex_subnet_range)
  tags = var.labels
}

#---------------------------------------
# Virtual Network Gateway Connection which binds together vpn gateway in Azure and local gateway in Yandex
#---------------------------------------
resource "azurerm_virtual_network_gateway_connection" "az-hub-onprem" {
  name                = "${var.azure_vnet_name}-yandex-hub"
  resource_group_name = var.rgname
  location            = var.location
  tags = var.labels
  type                       = "IPsec"
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.azure-vpn-gw.id
  local_network_gateway_id        = azurerm_local_network_gateway.localgw.id
  shared_key                      = yandex_kms_secret_ciphertext.psk-encrypted.ciphertext
  connection_protocol             = "IKEv2"

   ipsec_policy {
      dh_group         = "DHGroup2048"
      ike_encryption   = "AES128"
      ike_integrity    = "SHA256"
      ipsec_encryption = "AES128"
      ipsec_integrity  = "SHA256"
      pfs_group        = "PFS2048"
      sa_lifetime      = "3600"
  }
}



resource "time_sleep" "wait_30_seconds" {
  depends_on = [azurerm_virtual_network_gateway_connection.az-hub-onprem]

  create_duration = "30s"
}