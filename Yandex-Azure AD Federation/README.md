# Setting up federation in Yandex.Cloud through Azure AD

This repository provides a solution for setting up federation in [Yandex.Cloud](https://cloud.yandex.com/en/) with Azure Active Directory.

The detailed process for configuring Azure AD federation in Yandex.Cloud is described in the following documentation:
- [Authentication using Azure Active Directory](https://cloud.yandex.com/en/docs/organization/operations/federations/integration-azure)

This repository contains an example that allows to set up federation in an automated way.

<br/>

## Prerequisites

The list of prerequisite tools required to configure Azure Arc connectivity includes:
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [YC CLI](https://cloud.yandex.com/en-ru/docs/cli/operations/install-cli)
- [Terraform client](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [jq](https://stedolan.github.io/jq/)

<br/>

## Creating a SAML application in Azure

> This section is still in development and we hope to provide you with a more streamlined and automated process for configuring federation in the near future.

Create your SAML application in Azure Active Directory according to the "[Start creating an SAML app](https://cloud.yandex.com/en/docs/organization/operations/federations/integration-azure#configure-sso-azure-start)" section of the guide.

As a result, you should have the following URL's for your Enterprise Application:
- Azure SSO URL (`https://login.microsoftonline.com/<ID SAML-приложения>/saml2`)
- Azure AD Identifier (`https://sts.windows.net/<ID SAML-приложения>`)

<img src="images/az-saml-urls.jpg?raw=true" width="400px" alt="YC Login" title="YC Login"><br/>

<br/>

## Preparing environment

1. Please make sure that you have logged in YC CLI and initialized your profile.
2. Get your cloud-id, folder-id and organization-id with the following commands:
```
yc config list
yc organization-manager organization list
```
3. Create and fill the `private.auto.tfvars` file in the root of the `terraform` subfolder with the data acquired above. Contents of your `private.auto.tfvars' file might look like this as a result:
```
yc_folder_id    = "xxx"
yc_cloud_id     = "xxx"
yc_org_id       = "xxx"
az_issuer       = "https://sts.windows.net/xxx-yyy-zzz/"
az_sso_url      = "https://login.microsoftonline.com/xxx-yyy-zzz/saml2"
```
4. Check your authentication in Terraform `provider.tf` file: it might use `key.json` file or `token`.
5. Initialize Terraform module and apply it.

<br/>

## Yandex.Cloud Federation

Terraform module create a new federation with Azure AD and generates two post-installation Bash scripts that sohuld be used to finish the set up. 

After Terraform module has been applied, run the first script:
```
./scripts/1-get-federation.sh
```
The first script outputs the federation URL's required to finish the configuration from Azure AD side. The output might look like this:

```
YC Federation ID:
bpxxxxxx
---
Use the following URL for Identitifier (Entity ID) in Azure AD YC Login:
https://console.cloud.yandex.ru/federations/bpxxxxxx
---
Use the following URL for Reply URL in Azure AD YC Login:
https://console.cloud.yandex.ru/federations/bpxxxxxx
```

## Configuring Azure AD application

Please proceed to your Enterprise Application in Azure AD and fill the required URL's.
<img src="images/az-saml-config.jpg?raw=true" width="400px" alt="YC Login" title="YC Login"><br/>

<br/>

Download the SAML Signing Certificate in Base64 format and save it to `terraform/scripts/cert.cer`.

<img src="images/az-certificate.jpg?raw=true" width="400px" alt="YC Login" title="YC Login"><br/>

> The link for download will become active after the required URLs are filled.

After that, the resulting script to upload federation certificate can be run:
```
./scripts/2-upload-azure-cert.sh
```

<br/>

## Result

As a result, Azure AD federation is configured with the Yandex.Cloud Organization.
Authentication should be tested by opening the link `https://console.cloud.yandex.ru/federations/bpxxxxxx` and logging in with your Azure AD user account.

Successful login page looks like this:

<img src="images/yc-login-page.jpg?raw=true" width="600px" alt="YC Login" title="YC Login"><br/>

> Roles and permissions for clouds and folders should be added for the user.