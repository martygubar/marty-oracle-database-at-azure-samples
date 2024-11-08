# ensure you update the config file to match your deployment prior to running the deployment

source ./config

# Ask for confirmation
echo ""
echo "You are connected to:"
echo ""
az account show --query "{Name:name, TenantName:tenantDisplayName}" --output table
echo ""
echo "Are you sure you want to delete the resource group '$RESOURCE_GROUP'? All resources in that group WILL BE DELETED. This action cannot be undone."
echo "Enter (y/n)"
read confirmation

if [[ $confirmation == [yY] || $confirmation == [yY][eE][sS] ]]; then
    echo "Deleting Autonomous Database"
    az oracle-database autonomous-database delete --name $ADB_NAME --resource-group $RESOURCE_GROUP
    if [ $? -eq 0 ]; then
        echo "Database '$ADB_NAME' has been successfully deleted."
    fi    
    echo "Deleting resource group '$RESOURCE_GROUP'..."
    az group delete --name "$RESOURCE_GROUP" --yes
    if [ $? -eq 0 ]; then
        echo "Resource group '$RESOURCE_GROUP' has been successfully deleted."
    fi
else
    echo "Deletion cancelled. The resource group was not deleted."
fi