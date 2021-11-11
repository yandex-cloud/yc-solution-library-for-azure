
data "yandex_vpc_address" "vpn_address" {
  address_id = yandex_vpc_address.vpn_address.id
}




resource "yandex_compute_image" "vpn_instance" {
  source_family = "ipsec-instance-ubuntu"
}
#-------------------------------
# we render config template for ipsec instance
#-------------------------------
data "template_file" "vpn_cloud_init" {
  template = file("${path.module}/metadata/vpn.tpl.yaml")
  vars = {

    ssh_key     = file(var.public_key_path)
    left_id     = data.yandex_vpc_address.vpn_address.external_ipv4_address.0.address
    right      = data.azurerm_public_ip.azure-vpn-ip.ip_address
    leftsubnet  = var.yandex_subnet_range
    rightsubnet = flatten(var.azure_subnet_range) [0]
    psk         = yandex_kms_secret_ciphertext.psk-encrypted.ciphertext
  }
  depends_on = [
    time_sleep.wait_30_seconds
  ]
}

#-------------------------------
# yandex ipsec vpn instance which terminates vpn
#-------------------------------

resource "yandex_compute_instance" "vpn_vm" {
  name        = "vpn-vm"
  hostname    = "vpn-vm"
  description = "vpn-vm"
  zone        = var.zone
  platform_id = "standard-v3"
  labels      = var.labels

  resources {
    cores         = 4
    memory        = 4
    core_fraction = "100"
  }
  allow_stopping_for_update = true
  boot_disk {
    initialize_params {
      image_id = yandex_compute_image.vpn_instance.id
      type     = "network-ssd"
      size     = 33
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.this.id
    ip_address         = cidrhost(var.yandex_subnet_range, 10)
    nat                = true
    nat_ip_address     = data.yandex_vpc_address.vpn_address.external_ipv4_address.0.address
    security_group_ids = [yandex_vpc_security_group.this.id]
  }

  metadata = {
    user-data = data.template_file.vpn_cloud_init.rendered
  }
  
  depends_on = [
    azurerm_virtual_network_gateway_connection.az-hub-onprem, azurerm_virtual_network_gateway.azure-vpn-gw, azurerm_public_ip.azure-vpn-ip
  ]
}


