#!/usr/bin/env bash

set -euo pipefail

############################################
# Configuration
############################################

ENVIRONMENT="${1:-dev}"

LOCATION="northeurope"
RESOURCE_GROUP_NAME="tfstate-${ENVIRONMENT}-rg"

# Storage account rules:
# - lowercase
# - globally unique
# - 3-24 chars
# - no hyphens
STORAGE_ACCOUNT_NAME="tfstate${ENVIRONMENT}$(openssl rand -hex 3)"

CONTAINER_NAME="tfstate"

BACKEND_FILE="environments/${ENVIRONMENT}/backend.hcl"

############################################
# Validation
############################################

if ! command -v az >/dev/null 2>&1; then
  echo "ERROR: Azure CLI not installed."
  exit 1
fi

if ! az account show >/dev/null 2>&1; then
  echo "ERROR: Azure CLI not authenticated."
  echo "Run: az login"
  exit 1
fi

if [ ! -d "environments/${ENVIRONMENT}" ]; then
  echo "ERROR: Environment '${ENVIRONMENT}' does not exist."
  exit 1
fi

############################################
# Create Resource Group
############################################

echo "Creating resource group..."

az group create \
  --name "${RESOURCE_GROUP_NAME}" \
  --location "${LOCATION}"

############################################
# Create Storage Account
############################################

echo "Creating storage account..."

az storage account create \
  --resource-group "${RESOURCE_GROUP_NAME}" \
  --name "${STORAGE_ACCOUNT_NAME}" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --encryption-services blob

############################################
# Create Blob Container
############################################

echo "Creating blob container..."

az storage container create \
  --name "${CONTAINER_NAME}" \
  --account-name "${STORAGE_ACCOUNT_NAME}" \
  --auth-mode login

############################################
# Generate backend.hcl
############################################

echo "Generating backend configuration..."

cat > "${BACKEND_FILE}" <<EOF
resource_group_name  = "${RESOURCE_GROUP_NAME}"
storage_account_name = "${STORAGE_ACCOUNT_NAME}"
container_name       = "${CONTAINER_NAME}"
key                  = "${ENVIRONMENT}.terraform.tfstate"
EOF

############################################
# Done
############################################

echo ""
echo "Backend successfully created."
echo ""
echo "Backend config:"
echo "  ${BACKEND_FILE}"
echo ""
echo "Next steps:"
echo ""
echo "terraform init -backend-config=${BACKEND_FILE}"
