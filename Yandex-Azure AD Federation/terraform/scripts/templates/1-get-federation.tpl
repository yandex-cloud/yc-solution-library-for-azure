#!/bin/sh

# Creating Gitops configuration
YC_FED_ID=$(yc organization-manager federation saml list --organization-id=${org} --format json | jq -r ".[].id")

echo "YC Federation ID:"
echo $YC_FED_ID
echo "---"
echo "Use the following URL for Identitifier (Entity ID) in Azure AD SAML Configuration:"
echo "https://console.cloud.yandex.ru/federations/"$YC_FED_ID
echo "---"
echo "Use the following URL for Reply URL in Azure AD SAML Configuration:"
echo "https://console.cloud.yandex.ru/federations/"$YC_FED_ID