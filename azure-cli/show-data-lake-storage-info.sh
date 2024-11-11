#!/bin/bash
# Copyright (c) 2024 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/


# ensure you update the config file to match your deployment prior to running the deployment

source config

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

