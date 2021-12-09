# Yandex.Cloud Kubernetes cluster configuration file
output "k8s-cluster-name" {
  description = "You can use the name of the Kubernetes cluster to generate kube config file."
  value = "${yandex_kubernetes_cluster.yc_k8s_cluster.name}"
}