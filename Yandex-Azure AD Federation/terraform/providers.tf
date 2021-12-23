provider "yandex" {
  # service_account_key_file  = var.yc_auth
  token                     = var.yc_auth
  cloud_id                  = var.yc_cloud_id
  folder_id                 = var.yc_folder_id
}

provider "azuread" {
  tenant_id = var.az_tenant_id
  # Using Azure CLI authentication by default
}