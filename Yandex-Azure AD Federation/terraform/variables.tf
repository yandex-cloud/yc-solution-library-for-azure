variable "yc_auth" {
  description = "Yandex.Cloud service account key file"
  default     = "key.json" # https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token
}

variable "yc_folder_id" {
  description = "Yandex.Cloud folder-id"
  default     = "xxxxxx" # yc config get folder-id
}

variable "yc_cloud_id" {
  description = "Yandex.Cloud cloud-id"
  default     = "xxxxxx" # yc config get cloud-id
}

variable "yc_org_id" {
  description = "Yandex.Cloud organization-id"
  default     = "xxxxxx" # yc organization-manager organization list
}

variable "az_sso_url" {
  description = "Azure SSO URL"
  default     = "https://login.microsoftonline.com/<ID SAML-приложения>/saml2"
}

variable "az_issuer" {
  description = "Azure AD Identifier"
  default     = "https://sts.windows.net/<ID SAML-приложения>/"
}