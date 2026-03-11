**Título: Guía de Despliegue de Servidores - Arquitectura Silverback**

#### Objetivo
Estandarizar el aprovisionamiento de nuevos entornos para clientes corporativos utilizando IaC.

#### Pasos para agregar un nuevo servidor
1.  **Crear entorno:** Copia la carpeta `environments/template/` (o una existente) a `environments/cliente_X_prod/`.
2.  **Configurar variables:** Crea el archivo `terraform.tfvars` dentro de la carpeta del cliente siguiendo el esquema de tokens (`hcloud_token`, `cloudflare_api_token`, `cloudflare_zone_id`, `ssh_public_key`).
3.  **Ejecutar despliegue:**
    ```bash
    cd environments/cliente_X_prod/
    terraform init
    terraform plan -out=plan.out
    terraform apply "plan.out"
    ```
4.  **Verificación:** Terraform te devolverá la `ip_publica_X`.
5.  **Bootstrap de aplicación:**
    *   Entrar al servidor: `ssh root@<IP_PUBLICA>`
    *   `cd /src/silverback`
    *   `git clone <REPO_URL>`
    *   `make setup` (Esto configura los contenedores y el stack).
