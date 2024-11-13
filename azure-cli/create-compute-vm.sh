#!/bin/bash
# Copyright (c) 2024 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

echo ""
echo "##"
echo "# deploy compute vm"
echo "##"
echo ""

# ensure you update the config file to match your deployment prior to running the deployment
source ./config

VM_SIZE=""
IP_PUBLIC="${VM_NAME}-pip"
NIC_NAME="${VM_NAME}-nic"

# Function to find the first available size from the priority list
find_available_size() {

  #availableSizes=$(az vm list-sizes --location $LOCATION --query "[].name" -o tsv)
  availableSizes=$(az vm list-skus --location $LOCATION --resource-type virtualMachines --query "[?restrictions[?reasonCode=='NotAvailableForSubscription']].name" -o tsv)

  for size in "${VM_PREFERRED_SIZES[@]}" 
  do
    echo ""
    echo "search for $size"
    echo ""    
    if echo "$availableSizes" | grep -q "$size"; then
        echo ""
        echo "VM size $size is available in $LOCATION. Let's create the VM."
        VM_SIZE=$size
        break
    fi
  done  
}

# check if there are any available VMs
find_available_size

# if no VMs are available - bail.
if [ -z $VM_SIZE ]; then
    echo "No capacity for your VM sizes in $LOCATION. Unable to create a compute VM"
    exit -1
fi

# Create a public IP address for the VM
az network public-ip create \
    --resource-group $RESOURCE_GROUP \
    --name $IP_PUBLIC \
    --sku Standard

# Create a virtual NIC and associate with public IP address and NSG
az network nic create \
    --resource-group $RESOURCE_GROUP \
    --name $NIC_NAME \
    --vnet-name $VNET_NAME \
    --subnet $SUBNET2_NAME \
    --public-ip-address $IP_PUBLIC \
    --network-security-group $NSG_NAME

# Create a virtual machine
az vm create \
    --resource-group $RESOURCE_GROUP \
    --name $VM_NAME \
    --image $VM_IMAGE \
    --size $VM_SIZE \
    --admin-username $USER_NAME \
    --admin-password $USER_PASSWORD \
    --generate-ssh-keys \
    --nics $NIC_NAME 
