# Yandex.Cloud variables
variable "yc_folder_id" {
  description = "Yandex.Cloud folder id"
  type        = string
}

variable "yc_cloud_id" {
  description = "Yandex.Cloud cloud id"
  type        = string
}

variable "yc_zone" {
  description = "Yandex.Cloud region"
  type        = string
  default     = "ru-central1-a"
}

variable "yc_provider_key_file" {
  description = "Yandex.Cloud provider key file for authentication"
  default = "./key.json"

  # See documentation in the link below on how to create key.json service account file
  # https://cloud.yandex.com/en-ru/docs/iam/operations/iam-token/create-for-sa#keys-create
}

variable "yc_token" {
  description = "Yandex.Cloud authentication token"
  default = null
  
  # See documentation in the link below on how to obtain Oauth token for authentication
  # https://cloud.yandex.com/en-ru/docs/iam/concepts/authorization/oauth-token
}

variable "yc_existing_k8s_cluster_name" {
  description = "If Kubernetes cluster already exists in YC, please input cluster name"
  default     = ""
}

# Azure variables
variable "az_location" {
  description = "Azure Region"
  type        = string
  default     = "westeurope"
}

variable "az_resource_group_name" {
  description = "Azure resource group"
  type        = string
  default     = "azure-arc-demo"
}

variable "az_arc_cluster_name" {
  description = "Azure Arc Connected Kubernetes cluster name"
  type        = string
  default     = "azure-arc"
}

variable "az_subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "az_service_principal_app_id" {
  description = "Azure service principal App ID"
  type        = string
}

variable "az_service_principal_secret" {
  description = "Azure service principal App Password"
  type        = string
}

variable "az_service_principal_tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}