# bootstrap
Scripts para crear credenciales (formateadas para su uso) y recursos iniciales.

!!! Uso para laboratorios.

## az_github_actions.sh
Export json credenciales para configurar GitHub Actions

```bash
# Cloud Shell (bash)
bash <(wget -qO - https://raw.githubusercontent.com/gitrcr/bootstrap/refs/heads/main/az_github_actions.sh)
```

## az_terraform.sh
Export bloque de texto de credenciales para configurar terraform.tfvars

```bash
# Cloud Shell (bash)
bash <(wget -qO - https://raw.githubusercontent.com/gitrcr/bootstrap/refs/heads/main/az_terraform.sh)
```

* Escribir nombre de la cuenta de servicio
* Copiar el bloque entre "===="
* Sustituir el contenido del fichero de proyecto terraform.tfvars

## az_tfstate_blob.sh
Crear storage para tfstate de Terraform y export bloque de texto de credenciales para configurar el acceso: terraform.tfvars

```bash
# Cloud Shell (bash)
bash <(wget -qO - https://raw.githubusercontent.com/gitrcr/bootstrap/refs/heads/main/az_tfstate_blob.sh)
```

* Escribir nombre de la cuenta de servicio
* Copiar el bloque entre "===="
* Sustituir el contenido del fichero de proyecto terraform.tfvars

### Ref
Crear cuenta de servicio para despliegues automatizados. Role: Contributor

https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure-with-service-principle?tabs=bash