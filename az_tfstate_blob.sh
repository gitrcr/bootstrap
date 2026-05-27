#!/bin/bash

# --- 1. Configuración Inicial ---
# Generar nombre automático para el SP
random_id=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)
service_principal_name="tfaz${random_id}-sp"

# Datos de tu entorno
RESOURCE_GROUP=tf_rg${random_id}
STORAGE_ACCOUNT=tf_state${random_id}
CONTAINER_NAME=tfstate_blob${random_id}

echo "🚀 Iniciando configuración de Terraform en Azure..."

# --- 2. Obtener IDs de Suscripción y Tenant ---
subscription_id=$(az account show --query id --output tsv)
tenant_id=$(az account show --query tenantId --output tsv)
echo "✅ Suscripción: $subscription_id"
echo "✅ Tenant: $tenant_id"

# --- 3. Crear Service Principal ---
# Se crea con rol básico para permitir la asignación específica después
echo "🔐 Creando Service Principal: $service_principal_name..."
sp_output=$(az ad sp create-for-rbac \
  --name "$service_principal_name" \
  --role Reader \
  --scopes "/subscriptions/$subscription_id" \
  --output json)

# Extraer credenciales del JSON
client_id=$(echo $sp_output | jq -r '.appId')
client_secret=$(echo $sp_output | jq -r '.password')
object_id=$(az ad sp show --id $client_id --query id --output tsv)

echo "✅ Service Principal creado (App ID: $client_id)"

# --- 4. Asignar Permiso RBAC Específico al Contenedor (CLAVE) ---
# Esto reemplaza la necesidad de SAS_TOKEN o Access Keys
echo "🔑 Asignando rol 'Storage Blob Data Contributor' al contenedor..."

# Construir el scope exacto del contenedor
container_scope="/subscriptions/$subscription_id/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT/blobServices/default/containers/$CONTAINER_NAME"

az role assignment create \
  --assignee-object-id "$object_id" \
  --assignee-principal-type "ServicePrincipal" \
  --role "Storage Blob Data Contributor" \
  --scope "$container_scope"

if [ $? -eq 0 ]; then
    echo "✅ Permiso RBAC asignado correctamente al contenedor."
else
    echo "❌ Error al asignar el permiso RBAC. Verifica que el contenedor exista."
    exit 1
fi

# --- 5. Mostrar Instrucciones para GitHub Secrets ---
echo ""
echo "🎉 ¡Configuración completada!"
echo "Guarda estos valores en los Secrets de tu repositorio GitHub:"
echo ""
echo "ARM_CLIENT_ID=$client_id"
echo "ARM_CLIENT_SECRET=$client_secret"
echo "ARM_SUBSCRIPTION_ID=$subscription_id"
echo "ARM_TENANT_ID=$tenant_id"
echo ""
echo "⚠️  NOTA: No necesitas guardar ARM_SAS_TOKEN ni configurar resource_group_name en el backend si usas use_azuread_auth = true."   
