# bootstrap
Scripts para crear credenciales (formateadas para su uso) y recursos iniciales.

## az_github_actions.sh
!!! Uso solo para laboratorios.

Crear fichero JSON de credenciales para configurar GitHub Actions

Cloud Shell (bash)

```bash
bash <(wget -qO - https://raw.githubusercontent.com/gitrcr/bootstrap/refs/heads/main/az_github_actions.sh)
```

## az_terraform.sh
!!! Uso solo para laboratorios.

Crear cuenta de servicio para despliegues automatizados. Role: Contributor

https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure-with-service-principle?tabs=bash

* Acceder a Azure
* Abrir Cloud Shell
* Pegar y ejecutar el siguiente código:

```bash
bash <(wget -qO - https://raw.githubusercontent.com/gitrcr/bootstrap/refs/heads/main/az_terraform.sh)
```

* Escribir nombre de la cuenta de servicio
* Copiar el bloque entre "===="
* Sustituir el contenido del fichero de proyecto terraform.tfvars

## az_tfstate_blob.sh
!!! Uso solo para laboratorios.

Crear cuenta de servicio para despliegues automatizados. Role: Contributor

https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure-with-service-principle?tabs=bash

* Acceder a Azure
* Abrir Cloud Shell
* Pegar y ejecutar el siguiente código:

```bash
bash <(wget -qO - https://raw.githubusercontent.com/gitrcr/bootstrap/refs/heads/main/az_tfstate_blob.sh)
```

* Escribir nombre de la cuenta de servicio
* Copiar el bloque entre "===="
* Sustituir el contenido del fichero de proyecto terraform.tfvars