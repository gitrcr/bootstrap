#!/bin/bash

# --- 1. Configuración Inicial ---
# Generar nombre automático para el SP
random_id=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)
service_principal_name="tfaz${random_id}-sp"

# Datos de tu entorno
RESOURCE_GROUP="rg-terraform-state"
STORAGE_ACCOUNT="genstorage-pyweb"
CONTAINER_NAME="tfstate"

#!/bin/bash

# --- 1. Configuración Inicial ---
random_id=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)
service_principal_name="tfaz${random_id}-sp"

# MODIFICA ESTOS VALORES
LOCATION="eastus"
RESOURCE_GROUP="rg-terraform-state"
STORAGE_ACCOUNT="st${random_id}tfstate" # Debe ser único globalmente
CONTAINER_NAME="tfstate"

echo "🚀 Iniciando despliegue de infraestructura para Terraform..."

# --- 2. Crear Grupo de Recursos (Si no existe) ---
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

# --- 8. Resultado Final ---
echo ""
echo "🎉 ¡Infraestructura y Permisos listos!"
echo "Guarda estos valores en GitHub Secrets:"
echo ""
echo "ARM_CLIENT_ID=$client_id"
echo "ARM_CLIENT_SECRET=$client_secret"
echo "ARM_SUBSCRIPTION_ID=$subscription_id"
echo "ARM_TENANT_ID=$tenant_id"
echo ""
echo "Y actualiza tu backend.tf con:"
echo "  resource_group_name  = \"$RESOURCE_GROUP\""
echo "  storage_account_name = \"$STORAGE_ACCOUNT\""
echo "  container_name       = \"$CONTAINER_NAME\""
echo "  use_azuread_auth     = true"   

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
