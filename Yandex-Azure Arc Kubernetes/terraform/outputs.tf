output "next_step" {
  value     = "Please run the command: yc container cluster get-credentials --name ${try(module.example_k8s[0].k8s-cluster-name, var.yc_existing_k8s_cluster_name)} --external"
} 