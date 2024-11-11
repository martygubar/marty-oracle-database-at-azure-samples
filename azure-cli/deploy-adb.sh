#!/bin/bash

# Copyright (c) 2024 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

echo ""
echo "##"
echo "# deploy autonomous database"
echo "##"
echo ""
# ensure you update the config file to match your deployment prior to running the deployment

source ./config

# ADB requires the IDs of the networking components
VNET_ID=$(az network vnet show --resource-group $RESOURCE_GROUP --name $VNET_NAME --query id -o tsv)
SUBNET_ID=$(az network vnet subnet show --resource-group $RESOURCE_GROUP --vnet-name $VNET_NAME --name $SUBNET_NAME --query id -o tsv)

# create the database
az oracle-database autonomous-database create \
--location $LOCATION \
--autonomousdatabasename $ADB_NAME \
--resource-group $RESOURCE_GROUP \
--vnet-id $VNET_ID \
--subnet-id $SUBNET_ID \
--display-name $ADB_NAME \
--compute-model ECPU \
--compute-count 2 \
--cpu-auto-scaling true \
--data-storage-size-in-gbs 500 \
--store-auto-scaling true \
--backup-retention-period-in-days 7 \
--license-model BringYourOwnLicense \
--db-workload OLTP \
--db-version 23ai \
--regular \
--admin-password $USER_PASSWORD