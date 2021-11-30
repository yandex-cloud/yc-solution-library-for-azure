### Azure
# Resource Group
resource "azurerm_resource_group" "az_rg" {
  name     = var.az_resource_group_name
  location = var.az_location
}

### Yandex.Cloud
# Kubernetes Example Module
module "example_k8s" {
  count         = var.yc_existing_k8s_cluster_name == "" ? 1 : 0 // run block if condition is satisfied 
  source        = "./kubernetes"
  yc_folder_id  = var.yc_folder_id
  yc_cloud_id   = var.yc_cloud_id
  yc_zone       = var.yc_zone
}

### Post-installation scripts
data "template_file" "az_yc_arc_connect_script" {
  template = "${file("${path.module}/scripts/templates/az_connect_yandex_k8s.tpl")}"

  vars = {
    az_subscription_id              = "${var.az_subscription_id}"
    az_service_principal_app_id     = "${var.az_service_principal_app_id}"
    az_service_principal_secret     = "${var.az_service_principal_secret}"
    az_service_principal_tenant_id  = "${var.az_service_principal_tenant_id}"
    az_resource_group_name          = "${var.az_resource_group_name}"
    az_location                     = "${var.az_location}"
    az_arc_cluster_name             = "${var.az_arc_cluster_name}"
    yc_k8s_cluster_name             = "${var.yc_existing_k8s_cluster_name == "" ? module.example_k8s[0].k8s-cluster-name : var.yc_existing_k8s_cluster_name}"
    project                         = "azure-arc-demo"
  }
}

data "template_file" "az_yc_arc_gitops_script" {
  template = "${file("${path.module}/scripts/templates/az_arc_gitops_config.tpl")}"

  vars = {
    az_arc_cluster_name             = "${var.az_arc_cluster_name}"
    az_resource_group_name          = "${var.az_resource_group_name}"
    project                         = "azure-arc-demo"
    repo                            = "https://github.com/knpsh/k8s-app"
  }
}

resource "local_file" "az_yc_arc_connect_script" {
  content = data.template_file.az_yc_arc_connect_script.rendered
  filename = "${path.module}/scripts/az_yc_arc_connect_script.sh"
}

resource "local_file" "az_yc_arc_gitops_script" {
  content = data.template_file.az_yc_arc_gitops_script.rendered
  filename = "${path.module}/scripts/az_yc_arc_gitops_script.sh"
}