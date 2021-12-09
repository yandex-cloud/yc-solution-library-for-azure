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

variable "yc_k8s_version" {
  description = "Yandex.Cloud Kubernetes version"
  default     = "1.21"
}

variable "yc_k8s_channel" {
  description = "Yandex.Cloud Kubernetes update channel"
  default     = "RAPID"
}

variable "yc_k8s_cidr" {
  description = "Yandex.Cloud Kubernetes cluster CIDR"
  type        = list(string)
  default     = ["192.168.101.0/24"]
}