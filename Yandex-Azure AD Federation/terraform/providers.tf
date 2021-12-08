#provider "azurerm" {
#  features {}
#}

provider "yandex" {
  service_account_key_file  = var.yc_auth
  # token                     = "xxx"
  cloud_id                  = var.yc_cloud_id
  folder_id                 = var.yc_folder_id
}