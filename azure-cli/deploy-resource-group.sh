#!/bin/bash

echo ""
echo "##"
echo "# deploy resource group"
echo "##"
echo ""

# ensure you update the config file to match your deployment prior to running the deployment
source ./config

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION