# Azure Arc-enabled SQL Server

This guide provides easy-to-use scripts for connecting [Yandex.Cloud](https://cloud.yandex.com/en/) SQL server installed on a VM to [Microsoft Azure Arc](https://azure.microsoft.com/services/azure-arc/).


<br/>

## About

This repository contains an example that allows to deploy a new SQL VM with Microsoft SQL Server 2019 (Developer edition) in Yandex.Cloud and connect as an Azure Arc-enabled SQL server resource.

By the end of this example, you will have a Yandex.Cloud Windows Server 2019 VM with SQL Server 2019, projected as an Azure Arc-enabled SQL server and a running SQL assessment with data injected to Azure Log Analytics workspace.

<br/>
<img src="images/yc-azure-arc-sql.jpg?raw=true" width="800px" alt="Yandex.Cloud VM with SQL and Azure Arc" title="Yandex.Cloud VM with SQL and Azure Arc">
<br/><br/>


## Prerequisites

The list of prerequisites required to configure Azure Arc connectivity and GitOps includes:
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [YC CLI](https://cloud.yandex.com/en-ru/docs/cli/operations/install-cli)
- [Terraform client](https://learn.hashicorp.com/tutorials/terraform/install-cli)


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

Subscription must be enabled with the resource provider for Azure Arc. Registration process is asynchronous and may take several minutes.

```
az provider register --namespace Microsoft.AzureArcData
```

Registration process may be monitored with the following commands:

```
az provider show -n Microsoft.AzureArcData
```


<br/>

## Terraform module

Terraform module produces the following results:
1. Creates a new VM and installs SQL Developer Edition.
2. Creates a resource group in Azure.
3. Generates the script required to connect SQL VM to Azure Arc.
4. Adds the script to the VM logon process.
5. At first login, VM will be enabled in Azure Arc.


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
az_service_principal_app_id = "00000000-0000-0000-0000-000000000000"
az_service_principal_secret = "0000-0000-0000-0000-000000000000"
az_service_principal_tenant_id = "00000000-0000-0000-0000-000000000000"
az_subscription_id = "00000000-0000-0000-0000-000000000000"

vm_admin_user = "Administrator"
vm_admin_password = "AzureArcDemoPassw0rd!"

yc_folder_id = "b1g00000000000000000"
yc_cloud_id = "b1g00000000000000000"
```

Process of obtaining this information is described in the [Prerequisites](#prerequisites) section.
Keep in mind that `az_service_principal_secret` should be mapped with the `password` field of Service Principal creation output. Other fields' names are self-explanatory.

In case of Oauth token authentication, the following line containing Oauth token, should be added to the `private.auto.tfvars` file:
```
yc_token           = "OAUTH_TOKEN"
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

As a result, the new VM will be created in Yandex.Cloud, Azure resource group will be created, and PowerShell scripts will be generated in the `scripts` sub-folder. The scripts will be transferred to the VM. 


<br/>

## Post-installation tasks and scripts

After Terraform module deployment, please login to the VM with the username and password defined in `private.auto.tfvars` file [via RDP](https://cloud.yandex.com/en/docs/compute/operations/vm-connect/rdp). After the login, the PowerShell script will start to prepare the VM:

1. SQL Server Developer Edition will be installed.
2. Sample database will be restored.
3. Server will be onboarded in Azure Arc.
4. Azure Log Analytics workspace will be deployed and the MMA agent installed.
5. SQL Azure Assessment will be configured.

> Note: The script might take up to 30 minutes to prepare the VM.

<br/>

### Results

Yandex.Cloud VM with SQL as seen in the Azure resource group:

<img src="images/yc-azure-arc-sql-rg.jpg?raw=true" alt="Resource group in Azure" title="Resource group in Azure">
<br/>

<img src="images/yc-azure-arc-sql-server.jpg?raw=true" alt="Arc-enabled server in Azure" title="Arc-enabled server in Azure">
<br/><br/>

Log Analytics dashboard:

<img src="images/yc-azure-arc-sql-loganalytics.jpg?raw=true" alt="Arc-enabled server in Azure" title="Arc-enabled server in Azure">
<br/><br/>

### Azure SQL Assessment

Now that both the server and SQL projected as Azure Arc resources, complete the the SQL Assessment run.

On the `SQL Azure Arc` resource, click on `Environment Health` followed by clicking the `Download configuration script`.

Since the `LogonScript` script run in the deployment step took care of deploying and installing the required binaries, you can safely and delete the downloaded   `AddSqlAssessment.ps1` file.

Clicking the `Download configuration script` will simply send a REST API call to the Azure portal which will make `Step3` available and will result with a grayed-out `View SQL Assessment Results` button.

<img src="images/yc-azure-arc-sql-assess.jpg?raw=true" alt="Arc-enabled server in Azure" title="Arc-enabled server in Azure">
<br/><br/>

## Destroying

Run the following command to destroy created resources in Azure and Yandex.Cloud:
```
terraform destroy
```
