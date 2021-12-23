terraform {
  required_version = ">= 0.14.9"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.68"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "2.13.0"
    }
  }
}