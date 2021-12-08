resource "yandex_organizationmanager_saml_federation" federation {
  name                          = "azure-yc-federation"
  description                   = "Azure-YC Federation"
  organization_id               = var.yc_org_id
  sso_url                       = var.az_sso_url
  issuer                        = var.az_issuer
  cookie_max_age                = "12h"
  auto_create_account_on_login  = true
  sso_binding                   = "POST"
}

### Post-installation scripts
data "template_file" "yc-get-federation" {
  template = "${file("${path.module}/scripts/templates/1-get-federation.tpl")}"

  vars = {
    org             = "${var.yc_org_id}"
  }
}

data "template_file" "yc-upload-cert" {
  template = "${file("${path.module}/scripts/templates/2-upload-azure-cert.tpl")}"

  vars = {
    org             = "${var.yc_org_id}"
  }
}

resource "local_file" "yc-get-federation" {
  content = data.template_file.yc-get-federation.rendered
  filename = "${path.module}/scripts/1-get-federation.sh"
}

resource "local_file" "yc-upload-cert" {
  content = data.template_file.yc-upload-cert.rendered
  filename = "${path.module}/scripts/2-upload-azure-cert.sh"
}