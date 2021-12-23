# Setting up federation in Yandex.Cloud through Azure AD

This repository provides a solution for setting up federation in [Yandex.Cloud](https://cloud.yandex.com/en/) with Azure Active Directory.

The detailed process for configuring Azure AD federation in Yandex.Cloud is described in the following documentation:
- [Authentication using Azure Active Directory](https://cloud.yandex.com/en/docs/organization/operations/federations/integration-azure)

This repository contains an example that allows to set up federation in a semi-automated way.

<br/>

## Prerequisites

The list of prerequisite tools required to configure Azure Arc connectivity includes:
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [YC CLI](https://cloud.yandex.com/en-ru/docs/cli/operations/install-cli)
- [Terraform client](https://learn.hashicorp.com/tutorials/terraform/install-cli)

<br/>

## Preparing the environment

1. Please make sure that you have logged in YC CLI and initialized your profile.
2. Please make sure that you have logged in Azure CLI and initialized your profile.
3. Get your cloud-id, folder-id and organization-id with the following commands:
```
yc config list
yc organization-manager organization list
```
4. Get your Azure tenant ID using one of the following commands:
```
az login
az account list
az account tenant list
```
5. Create and fill the `private.auto.tfvars` file in the root of the `terraform` subfolder with the data acquired above. Contents of your `private.auto.tfvars` file might look like this as a result:
```
yc_folder_id    = "xxx"
yc_cloud_id     = "xxx"
yc_org_id       = "xxx"
az_tenant_id    = "xxx"
```
6. Check your Yandex.Cloud authentication in Terraform `provider.tf` file: it might use `key.json` file or `token`.
7. Initialize Terraform module and apply it:
```
terraform init
terraform apply
```

<br/>

## Yandex.Cloud Federation

Terraform module creates a new Azure enterprise application in the Azure tenant provided, and sets up federation in Yandex.Cloud with the Azure tenant. Some post-installation actions are still required, and these are described below.

After the Terraform module has been applied, the following output is displayed:
```
yc_federation_id = <<EOT
  Yandex.Cloud Federation ID is
  bpxxxxxxxxxxxx
  ---
  Use the following URL for Identitifier (Entity ID) in Azure AD SAML Configuration:
  https://console.cloud.yandex.ru/federations/bpxxxxxxxxxxxx
  ---
  Use the following URL for Reply URL in Azure AD SAML Configuration:"
  https://console.cloud.yandex.ru/federations/bpxxxxxxxxxxxx

EOT
```

This URL should be used to finish the setup in Azure.
Also note the Federation ID – you'll need it to upload the resulting certificate.

## Configuring Azure AD application

Please proceed to your [Enterprise Application](https://portal.azure.com/#blade/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/AllApps) in Azure AD, open Single Sign-On blade and choose SAML option, after that fill the required URL's with the URL from the output of the Teraform module.

<img src="images/az-saml-config.jpg?raw=true" width="400px" alt="YC Login" title="YC Login"><br/>

<br/>

Download the SAML Signing Certificate in Base64 format.

<img src="images/az-certificate.jpg?raw=true" width="400px" alt="YC Login" title="YC Login"><br/>

> The link for download will become active after the required URLs are filled.

Upload the certificate to complete the setup in Yandex.Cloud using the following command (use the Federation ID from the Teraform output above):
```
yc organization-manager federation saml certificate create --federation-id <FEDERATION_ID> --name "az-yc-federation" --certificate-file "az-yc-federation.cer"
```

<br/>

## Result

As a result, Azure AD federation is configured with the Yandex.Cloud Organization.
Authentication should be tested by opening the link `https://console.cloud.yandex.ru/federations/bpxxxxxx` and logging in with your Azure AD user account.

Successful login page looks like this:

<img src="images/yc-login-page.jpg?raw=true" width="600px" alt="YC Login" title="YC Login"><br/>

> Roles and permissions for Yandex.Cloud clouds and folders should be [added](https://console.cloud.yandex.ru/cloud?section=resource-acl) for the user. The role `resource-manager.clouds.member` is required to access the cloud along-side more service-centric roles – to access the services.

> Users should be allowed to use the federation in Enterprise Application properties:

<img src="images/az-assign-users.jpg?raw=true" width="400px" alt="YC Login" title="Assign users in Azure"><br/><br/>

## Delete the resources

If you need to delete the resources that were created, please run the following command:
```
terraform destroy
```