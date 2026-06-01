# bootstrap
Scritps repository

## az_github_actions.sh
GitHub Actions: exporta credenciales en formato json para configurar el secreto del entorno: AZURE_CREDENTIALS.

```bash
# Cloud Shell (bash)
bash <(wget -qO - https://raw.githubusercontent.com/gitrcr/bootstrap/refs/heads/main/azure/azgithub-actions.sh)
```

## tfaz-credentials.sh
Exporta bloque de texto (==== copiar entre ====) de credenciales para pegar en terraform.tfvars

```bash
# Cloud Shell (bash)
bash <(wget -qO - https://raw.githubusercontent.com/gitrcr/bootstrap/refs/heads/main/terraform/tfaz-credentials.sh)
```

## tfaz-state.sh
Crear storage para tfstate de Terraform y exporta bloque de texto (==== copiar entre ====) de credenciales para pegar en terraform.tfvars

```bash
# Cloud Shell (bash)
bash <(wget -qO - https://raw.githubusercontent.com/gitrcr/bootstrap/refs/heads/main/terraform/tfaz-state.sh)
```

### Ref:
Crear cuenta de servicio para despliegues automatizados. Role: Contributor

https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure-with-service-principle?tabs=bash