#!/usr/bin/env bash

set -euo pipefail

############################################
# Environment
############################################

ENVIRONMENT="${1:-dev}"

############################################
# Paths
############################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

############################################
# Auth bootstrap
############################################

echo ""
echo "STEP 1 - Azure authentication bootstrap"
echo ""

"${SCRIPT_DIR}/bootstrap-auth.sh"

############################################
# Load ARM variables
############################################

echo ""
echo "Loading ARM environment variables..."
echo ""

source .env.azurerm

############################################
# Backend bootstrap
############################################

echo ""
echo "STEP 2 - Terraform backend bootstrap"
echo ""

"${SCRIPT_DIR}/bootstrap-backend.sh" "${ENVIRONMENT}"

############################################
# Terraform init
############################################

echo ""
echo "STEP 3 - Terraform init"
echo ""

terraform init \
  -backend-config="environments/${ENVIRONMENT}/backend.hcl"

############################################
# Terraform validate
############################################

echo ""
echo "STEP 4 - Terraform validate"
echo ""

terraform validate

############################################
# Terraform plan
############################################

echo ""
echo "STEP 5 - Terraform plan"
echo ""

terraform plan

############################################
# Done
############################################

echo ""
echo "Bootstrap completed successfully."
