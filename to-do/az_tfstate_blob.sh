#!/bin/bash

# --- 1. Configuración Inicial ---
random_id=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)
service_principal_name="tfaz${random_id}-sp"

# Puedes modificar estos valores si lo deseas
LOCATION="eastus"
RESOURCE_GROUP="rg-terraform-state"
STORAGE_ACCOUNT="st${random_id}tfstate" # Debe ser único globalmente
CONTAINER_NAME="tfstate"
STATE_KEY="terraform.tfstate"

echo "🚀 Iniciando despliegue de infraestructura para Terraform..."

# --- 2. Crear Grupo de Recursos ---
echo "📦 Creando Grupo de Recursos: $RESOURCE_GROUP..."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none

# --- 3. Crear Cuenta de Almacenamiento ---
echo "💾 Creando Cuenta de Almacenamiento: $STORAGE_ACCOUNT..."
az storage account create \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --encryption-services blob \
  --output none

# --- 4. Crear Contenedor ---
echo "🗄️  Creando Contenedor: $CONTAINER_NAME..."
az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$STORAGE_ACCOUNT" \
  --output none

# --- 5. Obtener IDs de Suscripción y Tenant ---
subscription_id=$(az account show --query id --output tsv)
tenant_id=$(az account show --query tenantId --output tsv)

# --- 6. Crear Service Principal ---
echo "🔐 Creando Service Principal: $service_principal_name..."
sp_output=$(az ad sp create-for-rbac \
  --name "$service_principal_name" \
  --role Reader \
  --scopes "/subscriptions/$subscription_id" \
  --output json)

client_id=$(echo $sp_output | jq -r '.appId')
client_secret=$(echo $sp_output | jq -r '.password')
object_id=$(az ad sp show --id $client_id --query id --output tsv)

# --- 7. Asignar Permiso RBAC Específico al Contenedor ---
echo "🔑 Asignando rol 'Storage Blob Data Contributor'..."
container_scope="/subscriptions/$subscription_id/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT/blobServices/default/containers/$CONTAINER_NAME"

az role assignment create \
  --assignee-object-id "$object_id" \
  --assignee-principal-type "ServicePrincipal" \
  --role "Storage Blob Data Contributor" \
  --scope "$container_scope"

if [ $? -eq 0 ]; then
    echo "✅ Permiso RBAC asignado correctamente."
else
    echo "❌ Error al asignar permisos."
    exit 1
fi

# --- 8. Generar Bloque JSON Único para GitHub ---
echo ""
echo "🎉 ¡Infraestructura y Permisos listos!"
echo "---------------------------------------------------------"
echo "COPIA EL SIGUIENTE BLOQUE JSON Y GUÁRDALO EN GITHUB:"
echo "Nombre del secreto: AZURE_CREDENTIALS"
echo "---------------------------------------------------------"
cat <<EOF
{
  "clientId": "$client_id",
  "clientSecret": "$client_secret",
  "subscriptionId": "$subscription_id",
  "tenantId": "$tenant_id",
  "resourceGroup": "$RESOURCE_GROUP",
  "storageAccount": "$STORAGE_ACCOUNT",
  "containerName": "$CONTAINER_NAME",
  "key": "$STATE_KEY"
}
EOF
echo "---------------------------------------------------------"
echo "⚠️  IMPORTANTE: No añadas ningún otro secreto, este JSON lo contiene todo."   
