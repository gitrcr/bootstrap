#!/bin/bash
# start-lab.sh
# Propósito: Generar bloque de texto para copiar/pegar en tfvars desde Cloud Shell.
# No crea archivos locales, solo muestra el output en pantalla.

set -e

echo "🚀 Generando configuración para Lab Temporal (Azure Cloud Shell)"
echo "-----------------------------------------------------------------"

# 1. Obtener información de la suscripción actual
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
SUBSCRIPTION_NAME=$(az account show --query name -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)
LOCATION="northeurope" # Puedes cambiarlo si lo necesitas

# 2. Generar nombre único para la app
TIMESTAMP=$(date +%s)
APP_NAME="app${TIMESTAMP}"

# 3. Generar Service Principal Temporal (Opcional, si tu flujo lo requiere para el backend o recursos)
# Si tu flujo usa 'az login' directo (CLI Auth), puedes comentar esta sección y dejar las vars de cliente vacías.
# Aquí asumo que quieres un SP para el despliegue automático como en tu flujo original.
echo "🔐 Creando Service Principal temporal para el despliegue..."
SP_JSON=$(az ad sp create-for-rbac \
  --name "http://sp-${APP_NAME}" \
  --role "Contributor" \
  --scopes "/subscriptions/$SUBSCRIPTION_ID" \
  --query "{clientId:appId, clientSecret:password, tenantId:tenant}" \
  -o json 2>/dev/null)

CLIENT_ID=$(echo $SP_JSON | jq -r '.clientId')
CLIENT_SECRET=$(echo $SP_JSON | jq -r '.clientSecret')
# El Tenant ID ya lo tenemos, pero lo extraemos del SP por consistencia si cambia
SP_TENANT_ID=$(echo $SP_JSON | jq -r '.tenantId')

# 4. Mostrar el bloque formateado para COPIAR Y PEGAR
cat <<EOF

📋 COPIA EL SIGUIENTE BLOQUE Y PÉGALO EN TUS ARCHIVOS 'tfvars.rename' O 'terraform.tfvars':
========================================================================================
# --- Identidad y Backend (Service Principal Temporal) ---
tenant_id       = "$SP_TENANT_ID"
subscription_id = "$SUBSCRIPTION_ID"
client_id       = "$CLIENT_ID"
client_secret   = "$CLIENT_SECRET"

# --- Configuración del Laboratorio ---
app_name        = "$APP_NAME"
location        = "$LOCATION"
environment     = "apps"

# --- Configuración Web App Container ---
plan_sku        = "B1"
docker_image    = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
docker_registry = ""
docker_user     = ""
docker_pass     = ""
========================================================================================
⚠️  NOTA: Guarda el client_secret en un lugar seguro si planeas usarlo fuera de esta sesión.
          Este SP se creó con nombre: http://sp-${APP_NAME}

📝 Pasos siguientes:
1. Pega el bloque arriba en: environments/dev/tfvars.rename (y prod si aplica).
2. Renombra los archivos: mv environments/dev/tfvars.rename environments/dev/terraform.tfvars
3. Ejecuta tu script de inicialización local (.ps1) o 'terraform init'.
4. Ejecuta 'terraform apply' o usa tu dashboard.py.

========================================================================================
EOF   
