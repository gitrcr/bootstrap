#!/bin/bash

# Generar nombre automático
random_id=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)
service_principal_name="tfaz${random_id}-sp"

# Obtener IDs
subscription_id=$(az account show --query id --output tsv)
tenant_id=$(az account show --query tenantId --output tsv)

# Crear SP y capturar salida completa en formato TSV (appId + password)
az ad sp create-for-rbac --name "$service_principal_name" --role Contributor --scopes "/subscriptions/$subscription_id" --output json