terraform {
  required_version = "~> 1.0"
  required_providers {
    local   = "~> 1.4"
    http    = "~> 1.2.0"
    azurerm = "~> 2.25.0"
    yandex = {
      source = "yandex-cloud/yandex"
      version = "~> 0.67.0"
    }
  }
}

provider "yandex" {
  # Please select either service_account_key_file option or token option
  # The details on obtaining the tokens is provided in the links below:
  # https://cloud.yandex.com/en-ru/docs/iam/concepts/authorization/oauth-token
  # https://cloud.yandex.com/en-ru/docs/iam/operations/iam-token/create-for-sa#keys-create
  
  service_account_key_file  = var.yc_provider_key_file
  # token                     = var.yc_token
  cloud_id                  = var.yc_cloud_id
  folder_id                 = var.yc_folder_id
  zone                      = var.yc_zone
}

provider "azurerm" {
  subscription_id = var.az_subscription_id
  client_id       = var.az_service_principal_app_id
  client_secret   = var.az_service_principal_secret
  tenant_id       = var.az_service_principal_tenant_id
  features {}
}