#!/bin/bash

# Copyright (c) 2024 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

echo ""
echo "##"
echo "# Delete data lake storage account"
echo "##"
echo ""

# Ask for confirmation
echo ""
echo "Are you sure you want to delete the storage account $STORAGE_ACCOUNT_NAME in resource group '$RESOURCE_GROUP'? All containers and files will be deleted!"
echo "Enter (y/n)"
read confirmation

if [[ $confirmation == [yY] || $confirmation == [yY][eE][sS] ]]; then
    # ensure you update the config file to match your deployment prior to running the deployment
    source config
    az storage account delete -n $STORAGE_ACCOUNT_NAME -g $RESOURCE_GROUP
fi 
