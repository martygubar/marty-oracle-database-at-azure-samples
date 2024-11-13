#!/bin/bash
# Copyright (c) 2024 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

echo ""
echo "##"
echo "# deploy network"
echo "##"
echo ""
# ensure you update the config file to match your deployment prior to running the deployment
source ./config

# This client network will enable rdp access for VMs
az network nsg create \
    --resource-group $RESOURCE_GROUP \
    --name $NSG_NAME

# Enable RDP access
az network nsg rule create \
    --resource-group $RESOURCE_GROUP \
    --nsg-name $NSG_NAME \
    --name AllowRDP \
    --priority 1000 \
    --protocol Tcp \
    --direction Inbound \
    --source-address-prefix '*' \
    --source-port-range '*' \
    --destination-address-prefix '*' \
    --destination-port-range 3389 \
    --access Allow

# Allow external access to the internet for resources on the network
az network nsg rule create \
    --resource-group $RESOURCE_GROUP \
    --nsg-name $NSG_NAME \
    --name allow-internet \
    --protocol "*" \
    --direction outbound \
    --priority 100 \
    --destination-port-range "*" \
    --access allow


# Create virtual network with subnet for database
az network vnet create \
    --resource-group $RESOURCE_GROUP \
    --name $VNET_NAME \
    --address-prefixes $VNET_PREFIX \
    --subnet-name $SUBNET_NAME \
    --subnet-prefixes $SUBNET_PREFIX

# Make this a delegated subnet
az network vnet subnet update \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $SUBNET_NAME \
  --delegations "Oracle.Database/networkAttachments"

# Add a second subnet for client
az network vnet subnet create \
    --resource-group $RESOURCE_GROUP \
    --vnet-name $VNET_NAME \
    --name $SUBNET2_NAME \
    --address-prefixes $SUBNET2_PREFIX \
    --network-security-group $NSG_NAME