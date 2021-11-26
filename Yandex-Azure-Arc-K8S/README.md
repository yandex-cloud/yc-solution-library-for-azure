# Connecting Yandex.Cloud Managed Kubernetes cluster to Microsoft Azure Arc

This repository provides an easy-to-use solution for connecting [Yandex.Cloud](https://cloud.yandex.com/en/) [Managed Service for Kubernetes](https://cloud.yandex.com/en/services/managed-kubernetes) cluster to [Microsoft Azure Arc](https://azure.microsoft.com/services/azure-arc/).

Azure Arc allows customers to extend Azure management to any infrastructure and to simplify management of complex distributed hybrid environments.

The process of configuring Azure Arc-enabled Kubernetes cluster is described within the links below:
- [Connect an existing Kubernetes cluster to Azure Arc](https://azurearcjumpstart.io/azure_arc_jumpstart/azure_arc_k8s/general/onboard_k8s/)
- [Quickstart: Connect an existing Kubernetes cluster to Azure Arc](https://docs.microsoft.com/en-us/azure/azure-arc/kubernetes/quickstart-connect-cluster?tabs=azure-cli)

This repository contains an example that allows to deploy a new Kubernetes cluster and connect it to Azure Arc with pre-generated scripts.

(DIAGRAM)

## Prerequisites

The list of prerequisite tools required to configure Azure Arc connectivity includes:
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [YC CLI](https://cloud.yandex.com/en-ru/docs/cli/operations/install-cli)
- [Helm client](https://helm.sh/docs/intro/install/)
- [Terraform client](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [kubectl client](https://kubernetes.io/docs/tasks/tools/)

### Azure authentication

It is recommended to create a Service Principal which will be used for authentication purposes in Azure.
The process of creating a Service Principal includes the following steps:

1. Login to Azure CLI:
```
az login
```
2. List the subscriptions associated with the account:
```
az account list
```
3. Specify the subscription to use (if more than one available):
```
az account set --subscription="SUBSCRIPTION_ID"
```
4. Create the Service Principal which will be used to manage the resources:
```
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID"
```
5. The command above will output five values which will be used in this guide to deploy an example:
```
{
  "appId": "00000000-0000-0000-0000-000000000000",
  "displayName": "azure-cli-2021-00-00-00-00-00",
  "name": "http://azure-cli-2021-00-00-00-00-00",
  "password": "0000-0000-0000-0000-000000000000",
  "tenant": "00000000-0000-0000-0000-000000000000"
}
```

### Yandex.Cloud authentication

The process of setting up authentication is described below:

1. Login to YC CLI:
```
yc init
```
2. Provide the details required and initialize the profile.
3. Get the profile details (these details will be used in this guide):
```
yc config list
```
4. The command above should list the current configuration of the active profile, including `folder_id`, `cloud_id`, and `token`. This data will be used to deploy the example with Terraform.

### Resource providers

Subscription must be enabled with two resource providers for Azure Arc-enabled Kubernetes. Registration process is an asynchronous and may take up to 10 minutes.

```
az provider register --namespace Microsoft.Kubernetes
az provider register --namespace Microsoft.KubernetesConfiguration
az provider register --namespace Microsoft.ExtendedLocation
```

Registration process may be monitored with the following commands:

```
az provider show -n Microsoft.Kubernetes
az provider show -n Microsoft.KubernetesConfiguration
az provider show -n Microsoft.ExtendedLocation
```

## Terraform module

Terraform module provides the following results:
1. Creates a new Yandex.Cloud Kubernetes cluster
2. Creates a resource group in Azure
3. Generates the script required to configure Azure Arc connectivity
4. Generates the script required to configure GitOps feature in Azure Arc

### Yandex.Cloud provider

Either Oauth token or service account IAM token key file must be used for authentication.
Please select the suitable option in `providers.tf` file (uncomment one option and un-comment the other).

In case of service account key file authentication, the `key.json` file should be saved in the root of this (terraform) folder.

### Azure provider

Azure provider authentication is based on the Service Principal we have created earlier, in [Prerequisites](#prerequisites) section.

### Create private.auto.tfvars file

To use the Terraform module, it is recommended to create `private.auto.tfvars` file containing all the required variables. An example of such file and it's contents are provided below:

```
yc_folder_id    = "xxx"
yc_cloud_id     = "xxx"

az_subscription_id = "xxx"
az_service_principal_tenant_id = "xxx"
az_service_principal_app_id = "xxx"
az_service_principal_secret = "xxx"
```

Process of obtaining this information is described in the [Prerequisites](#prerequisites) section.
Keep in mind that `az_service_principal_secret` should be mapped with the `password` field of Service Principal creation output. Other fields' names are self-explanatory.

In case of Oauth token authentication, the following line containing Oauth token, should be added to the `private.auto.tfvars` file:
```
token           = "OAUTH_TOKEN"
```

## Run terraform

Initialize the Terraform module:
```
terraform init
```

Apply the Terraform configuration:
```
terraform apply
```

As a result, the new Kubernetes cluster will be created in Yandex.Cloud, Azure resource group will be created, and two bash-script files will be generated in the `scripts` sub-folder. 

## Post-installation tasks and scripts

After Terraform module deployment, kube config file must be generated for kubectl connectivity.
Then the generated bash-scripts must be run in sequence.

### Connect kubectl

Kubectl tool should be connected to Yandex.Cloud Kubernetes cluster.
This can be achieved with the steps following:

1. Create a new Kubernetes cluster or use an existing one (Kubernetes cluster must have a public IP address for external connectivity).
2. List existing Kubernetes clusters with YC CLI and copy the name of the cluster:
```
yc container cluster list
```
3. Create kubectl configuration file with the following command:
```
yc container cluster get-credentials --name CLUSTER_NAME --external
```
4. List the cluster nodes to test connectivity:
```
kubectl get nodes
```

### az_yc_arc_connect_script.sh

Run the `az_yc_arc_connect_script.sh` script located in `scripts` folder:
```
./az_yc_arc_connect_script.sh
```

This script is pre-filled with the data from Terraform module and can be run as it is.
As a result of running this script, Azure Arc connectivity will be set up, Cluster Connect feature will be enabled, and service account token will be displayed, which can be copied and pasted in Azure portal to display cluster-specific information.

### Results

Kubernetes cluster created in Yandex.Cloud is successfully connected to Azure Arc and it's configuration and resources are visible in Azure Arc portal.

(IMAGES)

## GitOps Integration

(PLACEHOLDER)
(DIAGRAM)

### az_yc_arc_gitops_script.sh

Run the `az_yc_arc_gitops_script.sh` script located in `scripts` folder:
```
./az_yc_arc_gitops_script.sh
```

This script is pre-filled with the data from Terraform module and can be run as it is.
As a result of running this script, GitOps configuration will be created, based on public Github repository.
Contents of Github repository (specifically yaml files containing the `hello` application service and deployment) will be deployed in Yandex.Cloud Kubernetes cluster. Any changes in the original application repository will be monitored and transferred to the actual deployment in the Kubernetes cluster.

### Results

GitOps configuration is created and the resources described in public GitHub are successfully provisioned.

(IMAGES)