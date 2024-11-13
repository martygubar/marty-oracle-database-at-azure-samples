#!/bin/bash
# Copyright (c) 2024 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

echo ""
echo "##"
echo "# deploy resource group"
echo "##"
echo ""

# ensure you update the config file to match your deployment prior to running the deployment
source ./config

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION