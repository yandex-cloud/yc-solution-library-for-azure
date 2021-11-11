
#-------------------------------
# Public ip address for VPN gateway in YANDEX
#-------------------------------
resource "yandex_vpc_address" "vpn_address" {
  name = "vpn-address"
  labels      = var.labels

  external_ipv4_address {
    zone_id = var.zone
  }
}


#-------------------------------
# subnet for resources protected by vpn tunnel in YANDEX
#-------------------------------
resource "yandex_vpc_subnet" "this" {
  name           = "${var.yandex_vpc_id}-vpn-subnet"
  zone           = var.zone
  network_id     = var.yandex_vpc_id
  v4_cidr_blocks = [var.yandex_subnet_range]
  route_table_id = yandex_vpc_route_table.this.id
  labels      = var.labels
}
#-------------------------------
# route table and route towards Azure subnet
#-------------------------------

 resource "yandex_vpc_route_table" "this" {
  name       = "azure-vpc-demo-rt"
  network_id = var.yandex_vpc_id
  labels      = var.labels

  static_route {
    destination_prefix = flatten(var.azure_subnet_range) [0]
    next_hop_address   = cidrhost(var.yandex_subnet_range, 10)
  }
}

#-------------------------------
# security group for yandex vpn instance
#-------------------------------

resource "yandex_vpc_security_group" "this" {
  name       = "azure-vpc-demo-sg"
  network_id = var.yandex_vpc_id
  labels      = var.labels


  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 500
  }

  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 4500
  }

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22

  }
  ingress {
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535


  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}