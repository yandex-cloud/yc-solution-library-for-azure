#!/bin/sh

YC_FED_ID=$(yc organization-manager federation saml list --organization-id=${org} --format json | jq -r ".[].id")

yc organization-manager federation saml certificate create --federation-id $YC_FED_ID --name "az-yc-federation-cert" --certificate-file "cert.cer"
echo "---"
echo "Login to Yandex.Cloud portal with your Azure credentials using link from the first script."