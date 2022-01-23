### Random string
resource "random_string" "project" {
  length          = 4
  upper           = false
  lower           = true
  number          = true
  special         = false
}

### Yandex.Cloud
# VPC
resource "yandex_vpc_network" "yc_vpc" {
  name            = "sql-arc-${random_string.project.result}"
  description     = "VPC for Arc-enabled SQL VM"
}

resource "yandex_vpc_subnet" "yc_subnet" {
  name       = "sql-arc-subnet-${random_string.project.result}"
  zone       = var.yc_zone
  network_id = yandex_vpc_network.yc_vpc.id
  v4_cidr_blocks = ["10.200.200.0/24"]
}
# Security Group
resource "yandex_vpc_security_group" "yc_sg" {
  name        = "sql-arc-sg-${random_string.project.result}"
  description = "SQL Arc-enabled VM Security Group"
  network_id  = yandex_vpc_network.yc_vpc.id

  ingress {
    protocol       = "TCP"
    description    = "incoming-rdp"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 3389
  }

  ingress {
    protocol       = "TCP"
    description    = "incoming-winrm"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 5985
    to_port        = 5986
  }

  egress {
    protocol       = "ANY"
    description    = "outgoing-all"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

# VM
resource "yandex_compute_instance" "yc_vm" {
  name        = var.vm_name
  platform_id = "standard-v3"

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = "fd803730irifbddaarmi" # Windows Server 2019
      size     = 100
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = "${yandex_vpc_subnet.yc_subnet.id}"
    nat                = true
    security_group_ids = [yandex_vpc_security_group.yc_sg.id]
  }

  metadata = {
    #user-data = "#ps1\nnet user ${var.vm_admin_user} ${var.vm_admin_password}"
    user-data = data.template_file.user_data.rendered
  }

  provisioner "file" {
    source      = "scripts/install_arc_agent.ps1"
    destination = "C:/tmp/install_arc_agent.ps1"

    connection {
      type     = "winrm"
      host     = self.network_interface.0.nat_ip_address
      port     = 5985
      user     = var.vm_admin_user
      password = var.vm_admin_password
      https    = false
      insecure = true
      timeout  = "10m"
    }
  }

  provisioner "file" {
    source      = "scripts/sql.ps1"
    destination = "C:/tmp/sql.ps1"

    connection {
      type     = "winrm"
      host     = self.network_interface.0.nat_ip_address
      port     = 5985
      user     = var.vm_admin_user
      password = var.vm_admin_password
      https    = false
      insecure = true
      timeout  = "10m"
    }
  }

  provisioner "file" {
    source      = "scripts/restore_db.ps1"
    destination = "C:/tmp/restore_db.ps1"

    connection {
      type     = "winrm"
      host     = self.network_interface.0.nat_ip_address
      port     = 5985
      user     = var.vm_admin_user
      password = var.vm_admin_password
      https    = false
      insecure = true
      timeout  = "10m"
    }
  }

  provisioner "file" {
    source      = "scripts/mma.json"
    destination = "C:/tmp/mma.json"

    connection {
      type     = "winrm"
      host     = self.network_interface.0.nat_ip_address
      port     = 5985
      user     = var.vm_admin_user
      password = var.vm_admin_password
      https    = false
      insecure = true
      timeout  = "10m"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "powershell.exe -File C://tmp//sql.ps1"
    ]

    connection {
      type     = "winrm"
      host     = self.network_interface.0.nat_ip_address
      port     = 5985
      user     = var.vm_admin_user
      password = var.vm_admin_password
      https    = false
      insecure = true
      timeout  = "10m"
    }
  }
}

### Azure
resource "azurerm_resource_group" "az_rg" {
  name     = var.az_resource_group_name
  location = var.az_location
}

resource "local_file" "sql_ps1" {
  content = templatefile("scripts/sql.ps1.tmpl", {
    admin_user               = var.vm_admin_user
    admin_password           = var.vm_admin_password
    resourceGroup            = var.az_resource_group_name
    location                 = var.az_location
    servicePrincipalAppId    = var.az_service_principal_app_id
    servicePrincipalSecret   = var.az_service_principal_secret
    servicePrincipalTenantId = var.az_service_principal_tenant_id
    }
  )
  filename = "scripts/sql.ps1"
}

resource "local_file" "install_arc_agent_ps1" {
  content = templatefile("scripts/install_arc_agent.ps1.tmpl", {
    resourceGroup            = var.az_resource_group_name
    location                 = var.az_location
    subId                    = var.az_subscription_id
    servicePrincipalAppId    = var.az_service_principal_app_id
    servicePrincipalSecret   = var.az_service_principal_secret
    servicePrincipalTenantId = var.az_service_principal_tenant_id
    }
  )
  filename = "scripts/install_arc_agent.ps1"
}

data "template_file" "user_data" {
  template = "${file("scripts/user_data.tpl")}"
  vars = {
    admin_user     = var.vm_admin_user
    admin_password = var.vm_admin_password
    hostname       = var.vm_name
  }
}