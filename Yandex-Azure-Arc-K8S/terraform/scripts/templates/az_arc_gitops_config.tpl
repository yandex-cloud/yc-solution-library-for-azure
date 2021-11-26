#!/bin/sh

# Creating Gitops configuration
echo "# Creating k8s-configuration for Gitops"
az k8s-configuration create --name ${project} --cluster-name ${az_arc_cluster_name} --resource-group ${az_resource_group_name} --operator-instance-name ${project} --operator-namespace ${project} --operator-params='--git-branch=main' --repository-url ${repo} --scope cluster --cluster-type connectedClusters