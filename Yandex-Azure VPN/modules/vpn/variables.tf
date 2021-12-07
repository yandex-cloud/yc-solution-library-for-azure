#-------------------------------
# Common Variables
#-------------------------------
variable "public_key_path" {
  description = "Path to public key file"
  default     = "~/.ssh/id_rsa.pub"
}

variable "labels" {
  description = "A set of key/value label pairs to assign."
  type        = map(string)
  default     = {
    "environment"        = "test"
    "service" = "vpn"
  }
}

#-------------------------------
# Yandex Variables
#-------------------------------
variable "zone" {
  description = "Yandex Cloud default Zone for provisoned resources"
  default     = "ru-central1-a"
}


variable "yandex_vpc_id" {
  description = "ID of the Yandex VPC where VPN instance will be created"
}

variable "yandex_subnet_range" {
  description = "Describe list of subnets that you wish to connect to the VPN from the Yandex.Cloud side"
  default = "192.168.0.0/24"
}

#-------------------------------
# Azure Variables
#-------------------------------

variable "location" {
  description = "azure location to create resources in"
}
variable "rgname" {
  description = "azure resource-group name to create the gateway"
}

variable "azure_vnet_name" {
  description = "name of the azure VNET where VPN gateway will be attached and GateWay subnet will be created"
}


variable "azure_subnet_range" {
  description = "Describe list of subnets that you wish to connect to the VPN from the Azure side"
  default = ["10.151.0.0/24"]
}

variable "azure_gateway_subnet_range" {
  description = "Describe subnet for vpn gateway in azure"
  default = ["10.0.255.0/24"]
}

