#!/bin/bash

# Generar nombre automático
random_id=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)
service_principal_name="lab${random_id}-sp"

# Obtener IDs
subscription_id=$(az account show --query id --output tsv)
tenant_id=$(az account show --query tenantId --output tsv)

# Crear SP y capturar salida completa en formato TSV (appId + password)
read client_id client_secret <<< $(az ad sp create-for-rbac \
  --name "$service_principal_name" \
  --role Contributor \
  --scopes "/subscriptions/$subscription_id" \
  --query '{appId: appId, password: password}' \
  --output tsv)

az account list-locations --subscription $subscription_id --output table   

read -p "Enter the location for blob storage container: " location

# Mostrar salida con formato solicitado
echo "### Insert the rows betwen "====" in the file terraform.tfvars ###"
echo "===="
echo "subscription_id = \"$subscription_id\""
echo "tenant_id       = \"$tenant_id\""
echo "client_id       = \"$client_id\""
echo "client_secret   = \"$client_secret\""   
echo "===="

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
