terraform {
  required_version = ">= 1.0.8"


  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.66"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.84"
    }
    template = {
      source = "hashicorp/template"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

provider "azurerm" {
features {}
}


### Datasource
data "yandex_client_config" "client" {}






