terraform {
  required_version = ">= 0.14.9"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.66"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }
}