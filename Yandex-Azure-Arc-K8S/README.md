# Azure Arc-enabled Yandex.Cloud Managed Kubernetes Cluster

This repository provides an easy-to-use scripts for connecting [Yandex.Cloud](https://cloud.yandex.com/en/) [Managed Service for Kubernetes](https://cloud.yandex.com/en/services/managed-kubernetes) cluster to [Microsoft Azure Arc](https://azure.microsoft.com/services/azure-arc/).


<br/>

## About

Azure Arc-enabled Kubernetes allows to attach and configure Kubernetes clusters running anywhere, including Kubernetes clusters running on [Yandex.Cloud](https://cloud.yandex.com/en/) platform. When you connect a Kubernetes cluster to Azure Arc, it will:

- Get an Azure Resource Manager representation with a unique ID.
- Be placed in an Azure subscription and resource group.
- Receive tags just like any other Azure resource.

Azure Arc-enabled Kubernetes supports industry-standard SSL to secure data in transit. For the connected clusters, data at rest is stored encrypted in an Azure Cosmos DB database to ensure data confidentiality.

Azure Arc allows customers to extend Azure management to any infrastructure and to simplify management of complex distributed hybrid environments.

The process of configuring Azure Arc-enabled Kubernetes cluster is described within the links below:
- [Connect an existing Kubernetes cluster to Azure Arc](https://azurearcjumpstart.io/azure_arc_jumpstart/azure_arc_k8s/general/onboard_k8s/)
- [Quickstart: Connect an existing Kubernetes cluster to Azure Arc](https://docs.microsoft.com/en-us/azure/azure-arc/kubernetes/quickstart-connect-cluster?tabs=azure-cli)

This repository contains an example that allows to deploy a new Kubernetes cluster and connect it to Azure Arc with pre-generated scripts.

<br/>
<img src="images/yc-azure-arc-k8s.jpg?raw=true" width="600px" alt="Yandex.Cloud Kubernetes and Azure Arc" title="Yandex.Cloud Kubernetes and Azure Arc">
<br/><br/>


After enabling Kubernetes cluster in Azure Arc, [GitOps](https://docs.microsoft.com/en-us/azure/azure-arc/kubernetes/tutorial-use-gitops-connected-cluster) can be enabled and used to deploy an application from public or private repository.

<br/>
<img src="images/yc-azure-arc-gitops.jpg?raw=true" width="600px" alt="Yandex.Cloud Kubernetes and Azure Arc Gitops" title="Yandex.Cloud Kubernetes and Azure Arc Gitops">
<br/><br/>


## Prerequisites

The list of prerequisites required to configure Azure Arc connectivity and GitOps includes:
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [YC CLI](https://cloud.yandex.com/en-ru/docs/cli/operations/install-cli)
- [Helm client](https://helm.sh/docs/intro/install/)
- [Terraform client](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [kubectl client](https://kubernetes.io/docs/tasks/tools/)


<br/>

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
5. The command above will output five values which will be used in this guide for deployment:
```
{
  "appId": "00000000-0000-0000-0000-000000000000",
  "displayName": "azure-cli-2021-00-00-00-00-00",
  "name": "http://azure-cli-2021-00-00-00-00-00",
  "password": "0000-0000-0000-0000-000000000000",
  "tenant": "00000000-0000-0000-0000-000000000000"
}
```

<br/>

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
4. The command above should list the current configuration of the active profile, including `folder_id`, `cloud_id`, and `token`. This data will be used for deployment with Terraform.

<br/>

### Resource providers

Subscription must be enabled with two resource providers for Azure Arc-enabled Kubernetes. Registration process is asynchronous and may take up to 10 minutes.

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


<br/>

## Terraform module

Terraform module provides the following results:
1. Creates a new Yandex.Cloud Kubernetes cluster or utilizes the existing one.
2. Creates a resource group in Azure.
3. Generates the script required to configure Azure Arc connectivity.
4. Generates the script required to configure GitOps feature in Azure Arc.


<br/>

### Yandex.Cloud provider

Either Oauth token or service account IAM token key file must be used for authentication.
Please select the suitable option in `providers.tf` file (uncomment one option and un-comment the other).

In case of service account key file authentication, the `key.json` file should be saved in the root of this (terraform) folder.


<br/>

### Azure provider

Azure provider authentication is based on the Service Principal we have created earlier, in [Prerequisites](#prerequisites) section.


<br/>

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
yc_token           = "OAUTH_TOKEN"
```

In case you already have an existing Kubernetes cluster and want to enable it with Azure Arc, please add the following line containing the name of the cluster (as it named in the Yandex.Cloud) in the `private.auto.tfvars` file:
```
yc_existing_k8s_cluster_name = "K8S_CLUSTER_NAME"
```

<br/>

## Run terraform

Initialize the Terraform module:
```
terraform init
```

Apply the Terraform configuration:
```
terraform apply
```

As a result, the new Kubernetes cluster will be created in Yandex.Cloud (if there is no existing one), Azure resource group will be created, and two bash-script files will be generated in the `scripts` sub-folder. 


<br/>

## Post-installation tasks and scripts

After Terraform module deployment, kube config file must be generated for kubectl connectivity.
Then the generated bash-scripts must be run in sequence.


<br/>

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


<br/>

### az_yc_arc_connect_script.sh

Run the `az_yc_arc_connect_script.sh` script located in `scripts` folder:
```
./az_yc_arc_connect_script.sh
```

This script is pre-filled with the data from Terraform module and can be run as it is.
As a result of running this script, Azure Arc connectivity will be set up, Cluster Connect feature will be enabled, and service account token will be displayed, which can be copied and pasted in Azure portal to display cluster-specific information.

<br/>
<img src="images/azure-arc-token.jpg?raw=true" width="400px" alt="Azure Arc Service Account Token Authentication" title="Azure Arc Service Account Token Authentication">
<br/><br/>

### Results

Kubernetes cluster created in Yandex.Cloud is successfully connected to Azure Arc and it's configuration and resources are visible in Azure Arc portal.

<img src="images/yc-azure-arc-connected.jpg?raw=true" width="600px" alt="Azure Arc Kubernetes Cluster Connected" title="Azure Arc Kubernetes Cluster Connected"><br/>
<img src="images/yc-azure-arc-workloads.jpg?raw=true" width="600px" alt="Azure Arc Kubernetes Cluster Workloads" title="Azure Arc Kubernetes Cluster Workloads">


<br/>

## GitOps Integration

GitOps integration allows to deploy application from Git repository in the Arc-enabled Kubernetes cluster and continuously monitor for changes in the repository and apply them. 

GitOps example in this solution deploys application called `hello-app` in the Arc-enabled Kubernetes cluster.


<br/>

### az_yc_arc_gitops_script.sh

Run the `az_yc_arc_gitops_script.sh` script located in `scripts` folder:
```
./az_yc_arc_gitops_script.sh
```

This script is pre-filled with the data from Terraform module and can be run as it is.
As a result of running this script, GitOps configuration will be created, based on public Github repository.
Contents of Github repository (specifically yaml files containing the `hello` application service and deployment) will be deployed in Yandex.Cloud Kubernetes cluster. Any changes in the original application repository will be monitored and transferred to the actual deployment in the Kubernetes cluster.


<br/>

### Results

GitOps configuration is created and the resources described in public GitHub are successfully provisioned and visible in Azure Arc portal.

Resources specific to `hello-app` in a cluster:

<img src="images/yc-azure-arc-gitops-resources.jpg?raw=true" width="400px" alt="Azure Arc GitOps Resources" title="Azure Arc GitOps Resources"><br/>

`hello-app` service as visible in a cluster:

<img src="images/yc-azure-arc-hello-service-k8s.jpg?raw=true" width="400px" alt="Hello App Service in K8s" title="Hello App Service in K8s"><br/>

`hello-app` service as visible in Azure Arc:

<img src="images/yc-azure-arc-hello-service.jpg?raw=true" width="600px" alt="Hello App Service in Azure Arc" title="Hello App Service in Azure Arc"><br/>

Running `hello-app` as seen through the external IP address:

<img src="images/yc-azure-arc-hello-app.jpg?raw=true" width="400px" alt="Hello App in Azure Arc" title="Hello App in Azure Arc"><br/><br/>

### Next steps

The following content will be developed and added next:
- Insights and Monitoring with Azure Arc
- Microsoft Defender for Cloud with Azure Arc
- GitOps CI/CD pipeline
