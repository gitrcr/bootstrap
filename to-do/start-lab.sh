#!/bin/bash
# start-lab.sh
# Propósito: Iniciar un entorno de laboratorio temporal de 2 horas sin edición manual de tfvars.

set -e

echo "🚀 Iniciando Azure Lab Session (Duración estimada: 2h)"
echo "-------------------------------------------------------"

# 1. Obtener información de la suscripción actual
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
SUBSCRIPTION_NAME=$(az account show --query name -o tsv)
LOCATION="eastus" # Puedes cambiar esto o pedirlo por input

# 2. Generar nombre único para el lab (evita colisiones)
TIMESTAMP=$(date +%s)
LAB_NAME="lab${TIMESTAMP}"
SP_NAME="http://sp-${LAB_NAME}"

echo "📝 Nombre del Lab: $LAB_NAME"
echo "📍 Región: $LOCATION"

# 3. Crear Service Principal temporal con permisos de Contribuidor
# Nota: Para un lab de 2h, 'Contributor' en la suscripción es aceptable por comodidad.
# En producción, limita el --scopes a un Resource Group específico.
echo "🔐 Creando Service Principal temporal..."
SP_JSON=$(az ad sp create-for-rbac \
  --name "$SP_NAME" \
  --role "Contributor" \
  --scopes "/subscriptions/$SUBSCRIPTION_ID" \
  --query "{clientId:appId, clientSecret:password, tenantId:tenant}" \
  -o json)

# 4. Exportar credenciales a variables de entorno (Solo viven en esta terminal)
export ARM_CLIENT_ID=$(echo $SP_JSON | jq -r '.clientId')
export ARM_CLIENT_SECRET=$(echo $SP_JSON | jq -r '.clientSecret')
export ARM_TENANT_ID=$(echo $SP_JSON | jq -r '.tenantId')
export ARM_SUBSCRIPTION_ID=$SUBSCRIPTION_ID

# Guardar el ID del SP para poder borrarlo luego (opcional)
echo $ARM_CLIENT_ID > .sp_app_id_temp

echo "✅ Credenciales cargadas en memoria."

# 5. Generar archivo de variables NO sensibles (lab.auto.tfvars)
# Este archivo se puede commitear o generar dinámicamente, no contiene secretos.
cat <<EOF > lab.auto.tfvars
# Configuración del Laboratorio Temporal
lab_name        = "$LAB_NAME"
location        = "$LOCATION"
environment     = "lab"

# Configuración Web App Container
plan_sku        = "B1"
docker_image    = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
docker_registry = ""
docker_user     = ""
docker_pass     = ""
EOF

echo "📄 Archivo 'lab.auto.tfvars' generado con configuración por defecto."
echo "-------------------------------------------------------"
echo "⚠️  IMPORTANTE: No cierres esta terminal hasta finalizar el lab."
echo "Las credenciales desaparecerán si cierras la sesión."
echo ""
echo "Siguientes pasos:"
echo "1. Clona/Actualiza tu repo local si es necesario."
echo "2. Ejecuta: terraform init"
echo "3. Ejecuta: terraform plan"
echo "4. O usa tu dashboard: python dashboard.py"
echo "-------------------------------------------------------"   
