#!/bin/bash
az account list-locations --subscription $subscription_id --output table   

read -p "Enter the location for blob storage container: " location

RESOURCE_GROUP_NAME=tfstate
STORAGE_ACCOUNT_NAME=tfazstate${random_id}
CONTAINER_NAME=tfstate

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location $location

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME

echo "Storage Account  = \"$STORAGE_ACCOUNT_NAME\""
