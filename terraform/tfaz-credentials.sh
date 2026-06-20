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

# Mostrar salida con formato solicitado
echo "### Insert the rows betwen "====" in the file terraform.tfvars ###"
echo "===="
echo "subscription_id = \"$subscription_id\""
echo "tenant_id       = \"$tenant_id\""
echo "client_id       = \"$client_id\""
echo "client_secret   = \"$client_secret\""   
echo "===="
echo "export ARM_CLIENT_ID=\"$subscription_id\""
echo "export ARM_CLIENT_SECRET=\"$client_secret\""
echo "export ARM_SUBSCRIPTION_ID=\"$client_id\""
echo "export ARM_TENANT_ID=\"$tenant_id\""
echo "===="
