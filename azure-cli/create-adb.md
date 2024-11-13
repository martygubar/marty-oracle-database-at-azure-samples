# Oracle Database@Azure: Create an Autonomous Database
The steps below show how to create an Autonomous Database using the Azure CLI. 

Prerequisites:
* [Install the Azure CLI](https://learn.microsoft.com/en-us/cli/azure/) 
* Subscribe to Oracle Database@Azure. 
* Ensure you have the appropriate user groups and privileges. See [details for onboarding Autonomous Database](https://learn.microsoft.com/en-us/azure/oracle/oracle-db/onboard-oracle-database)

## Deploy your Autonomous Database
Use the following scripts to deploy your infrastructure and Autonomous Database. You can run the scripts independently or run `create-all-resources.sh`. Simply update the [`config`](#configuration-file) prior to running the scripts:

|Script|Description|
|----|---|
|[create-resource-group.sh](create-resource-group.sh)|Create a resource group|
|[create-network.sh](create-network.sh)|Create virtual cloud network. <br><br>ADB must be deployed to a delegated subnet. In addition, ADB access is thru a private endpoint. This means it must be accessed from either the same VCN or another privileged network.|
|[create-adb.sh](create-adb.sh)|Create an Autonomous Database|
|[create-compute-vm.sh](create-compute-vm.sh)|Create a VM in that VCN|
|[create-all-resources.sh](create-all-resources.sh)|Creates your resource group, network, ADB and VM|
|[create-data-lake-storage.sh](create-data-lake-storage.sh)|Creates an Azure Data Lake Gen 2 storage account, a container and uploads sample data into that container|
|[delete-all-resources.sh](delete-all-resources.sh)|Deletes your resource group, network, ADB and VM|

### Configuration file
The Azure cli deployment scripts rely on settings found in the config file. These resources **will be created** by the scripts. Update the config file prior to running any of the scripts. 

>**IMPORTANT:** This file will contain a password that is used to connect to Autonomous Database and the virtual machine. Set the file's permissions so that only the file's owner can view its contents:
```bash
chmod 600 config
```

|Setting|Description|Example|
|----|----|----|
|LOCATION|Region where resources will be deployed. [See documentation](https://docs.oracle.com/en-us/iaas/Content/database-at-azure/oaa_regions.htm) for regions where Oracle Database 23ai is available|"eastus"|
|RESOURCE_GROUP|Target resource group for new resources|"development"|
|ADB_NAME|Autonomous Database name. This name must be unique within a region location|"quickstart"|
|VNET_NAME|Virtual network|"dev-vnet"|
|VNET_PREFIX|CIDR range for the virtual network|"192.168.0.0/16"|
|SUBNET_NAME|Delegated subnet where the database will be deployed|"dev-sn-db"|
|SUBNET_PREFIX|CIDR range for the delegated subnet|"192.168.1.0/24"|
|SUBNET2_NAME|Client subnet. The VM will be deployed to this subnet|"dev-sn-client"|
|SUBNET2_PREFIX|CIDR range for the client subnet|"192.168.2.0/24"|
|NSG_NAME|Name of the network security group used by the client subnet|$SUBNET2_NAME-nsg|
|VM_NAME|Name of the virtual machine|"adb-vm-client"|
|VM_PREFERRED_SIZES|A list of VM sizes. Change these values based on region availability. The script will attempt to create a VM based on the order listed|( "Standard_GS1" "Standard_DC1s_v2" "Standard_DC2s_v2" "Standard_DC2ads_v5" "Standard_L4s"  )|
|VM_IMAGE|The image used by the VM|"MicrosoftWindowsDesktop:Windows-11:win11-22h2-pro:latest"|
|STORAGE_ACCOUNT_NAME|The name of an Azure Data Lake Storage Gen 2 account. This name must be unique across Azure. Sample data files will be uploaded into this storage account.|"mytenancysamplestorageaccount"|
|STORAGE_CONTAINER_NAME|The name of the container where files will be uploaded|"adb-sample"|
|USER_NAME|The name of the user for the virtual machine|"adb"|
|USER_PASSWORD|The password for both the VM and the Autonomous Database admin user|"Welcome1234#abcd"|

### Using the scripts
After updating the config file: 

Log into azure:
```bash
az login 
```
Then, run your scripts. The following will deploy a complete environment:
After a few minutes, review your newly created database:
```bash
./create-all-resources.sh
```

<hr>
Copyright (c) 2024 Oracle and/or its affiliates.<br>
Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/
