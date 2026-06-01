#!/usr/bin/env bash

set -euo pipefail

############################################
# Validation
############################################

if ! command -v az >/dev/null 2>&1; then
  echo "ERROR: Azure CLI not installed."
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq not installed."
  exit 1
fi

if ! az account show >/dev/null 2>&1; then
  echo "ERROR: Azure CLI not authenticated."
  echo "Run: az login"
  exit 1
fi

############################################
# Subscription
############################################

SUBSCRIPTION_ID=$(az account show --query id --output tsv)

echo ""
echo "Active subscription:"
echo "  ${SUBSCRIPTION_ID}"
echo ""

############################################
# Service Principal name
############################################

read -rp "Service Principal name: " SERVICE_PRINCIPAL_NAME

############################################
# Create SP
############################################

echo ""
echo "Creating Service Principal..."
echo ""

SP_OUTPUT=$(az ad sp create-for-rbac \
  --name "${SERVICE_PRINCIPAL_NAME}" \
  --role Contributor \
  --scopes "/subscriptions/${SUBSCRIPTION_ID}" \
  --output json)

############################################
# Extract values
############################################

CLIENT_ID=$(echo "${SP_OUTPUT}" | jq -r '.appId')
CLIENT_SECRET=$(echo "${SP_OUTPUT}" | jq -r '.password')
TENANT_ID=$(echo "${SP_OUTPUT}" | jq -r '.tenant')

############################################
# Export file
############################################

ENV_FILE=".env.azurerm"

cat > "${ENV_FILE}" <<EOF
export ARM_CLIENT_ID="${CLIENT_ID}"
export ARM_CLIENT_SECRET="${CLIENT_SECRET}"
export ARM_SUBSCRIPTION_ID="${SUBSCRIPTION_ID}"
export ARM_TENANT_ID="${TENANT_ID}"
EOF

chmod 600 "${ENV_FILE}"

############################################
# Output
############################################

echo ""
echo "Service Principal successfully created."
echo ""
echo "Credentials exported to:"
echo "  ${ENV_FILE}"
echo ""
echo "Load credentials:"
echo ""
echo "source ${ENV_FILE}"
echo ""
echo "Validate:"
echo ""
echo "env | grep ARM_"
