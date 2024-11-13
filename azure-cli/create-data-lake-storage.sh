#!/bin/bash
# Copyright (c) 2024 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

echo ""
echo "##"
echo "# Create an Azure Data Lake Storage Gen 2 account"
echo "##"
echo ""
# ensure you update the config file to match your deployment prior to running the deployment

source config

echo "# Creating storage account $STORAGE_ACCOUNT_NAME"
az storage account create \
    --name $STORAGE_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --sku Standard_LRS \
    --kind StorageV2 \
    --min-tls-version TLS1_2 \
    --https-only true \
    --allow-blob-public-access true \
    --allow-shared-key-access true \
    --default-action Allow \
    --bypass AzureServices \
    --access-tier Cool \
    --public-network-access Enabled \
    --encryption-key-source Microsoft.Storage 

# Enable access via the portal
az storage account update \
    --name $STORAGE_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP \
    --default-action Allow 

echo "# Creating container $STORAGE_CONTAINER_NAME"
az storage container create \
    --name $STORAGE_CONTAINER_NAME \
    --account-name $STORAGE_ACCOUNT_NAME

ACCESS_KEY=`az storage account keys list --account-name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --query "[0].value" -o tsv`

# Attempt to give current user access to the storage account
echo "# Give privs to access the storage account to the currently signed in user"

STORAGE_ACCOUNT_ID=`az storage account show --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --query id -o tsv`
USER_PRINCIPAL_NAME=`az ad signed-in-user show --query userPrincipalName -o tsv`
az role assignment create --assignee "$USER_PRINCIPAL_NAME" --role "Storage Blob Data Owner" --scope $STORAGE_ACCOUNT_ID


echo "# Uploading sample files"

echo "Create the support site directory"
az storage fs directory create \
    --account-name $STORAGE_ACCOUNT_NAME \
    --file-system $STORAGE_CONTAINER_NAME \
    --name support-site \
    --account-key $ACCESS_KEY

echo "Upload files to that directory"
az storage fs directory upload \
    --account-name $STORAGE_ACCOUNT_NAME \
    --file-system $STORAGE_CONTAINER_NAME \
    --source "../sql/support-site/*" \
    --destination-path support-site \
    --recursive \
    --auth-mode login

echo "Create the data directory"
az storage fs directory create \
    --account-name $STORAGE_ACCOUNT_NAME \
    --file-system $STORAGE_CONTAINER_NAME \
    --name data \
    --account-key $ACCESS_KEY

echo "Upload files to that directory"
az storage fs directory upload \
    --account-name $STORAGE_ACCOUNT_NAME \
    --file-system $STORAGE_CONTAINER_NAME \
    --source "../sql/data/*" \
    --destination-path data \
    --recursive \
    --auth-mode login

echo "Done."
az storage blob list \
    --account-name $STORAGE_ACCOUNT_NAME \
    --container-name $STORAGE_CONTAINER_NAME \
    --output table --auth-mode login

echo ""
echo "Storage account: $STORAGE_ACCOUNT_NAME" 
echo "Container name : $STORAGE_CONTAINER_NAME" 
echo "Access Key:"

az storage account keys list \
    --account-name $STORAGE_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP --query "[0].value" -o tsv    

echo "Storage URL:"
az storage account show \
    --name $STORAGE_ACCOUNT_NAME \
    --query primaryEndpoints.blob \
    --output tsv
echo ""
