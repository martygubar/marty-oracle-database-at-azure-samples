#!/bin/bash
# Copyright (c) 2024 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

echo ""
echo "##"
echo "# show autonomous database info"
echo "##"
echo ""

# ensure you update the config file to match your deployment prior to running the deployment
source ./config
az oracle-database autonomous-database show \
    --name $ADB_NAME \
    --resource-group $RESOURCE_GROUP \
    --query "connectionStrings.profiles[?consumerGroup=='Medium'] | [0]"