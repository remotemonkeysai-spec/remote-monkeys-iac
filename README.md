# README.md

# Remote Monkeys - Infraestructura como Código (IaC) - Arquitectura "Silverback"

Este repositorio contiene la lógica de aprovisionamiento automatizado para los despliegues de la arquitectura **Silverback** (basada en Hetzner Cloud, Docker, Traefik y optimizada para Agentes de IA).

## 🚀 Arquitectura
*   **Provider Cloud:** Hetzner (Ubuntu 24.04).
*   **Proxy / Edge:** Traefik (integrado con Docker, SSL automático vía Cloudflare).
*   **Orquestación:** Docker + Docker Compose V2.
*   **Hardening:** UFW (Firewall) restringido solo a rangos IP de Cloudflare, SSH con llaves públicas.
*   **Stack:** PostgreSQL (pgvector), n8n, Redis, Next.js, Traefik.

## 📂 Estructura del Proyecto
*   `/modules/silverback`: El "blueprint" de tu servidor. Contiene la lógica central (VPS, Firewall, DNS, Bootstrapping).
*   `/environments/`: Carpetas por cliente (ej. `cliente_t1_prod`). Aquí vive la configuración específica de cada despliegue.

## 🛠️ Requisitos Previos
1. **Terraform instalado:** `sudo apt-get install terraform`.
2. **Hetzner API Token:** Con permisos de creación de recursos.
3. **Cloudflare API Token:** Con permisos de `Zone:DNS:Edit` y `Zone:Settings:Edit`.
4. **Llave SSH:** Tu llave pública (`~/.ssh/id_ed25519.pub`).

## ⚙️ Configuración (Pasos para desplegar un cliente)

### 1. Preparar el entorno del cliente
Crea o navega a la carpeta de tu cliente (ej. `environments/cliente_t1_prod/`).

### 2. Configurar variables sensibles
Crea un archivo llamado `terraform.tfvars` en esa carpeta (este archivo **NO** se sube a Git):
```hcl
hcloud_token         = "TU_TOKEN_HETZNER"
cloudflare_api_token = "TU_TOKEN_CLOUDFLARE"
cloudflare_zone_id   = "TU_ZONE_ID_DE_CLOUDFLARE"
ssh_public_key       = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5..."
```

### 3. Desplegar
Ejecuta los siguientes comandos dentro de la carpeta del cliente:
1.  **`terraform init`** (Solo la primera vez).
2.  **`terraform plan`** (Revisa los cambios que se van a aplicar).
3.  **`terraform apply`** (Confirma con `yes` para aprovisionar).

## 🔒 Notas de Seguridad
*   **Acceso SSH:** El usuario `root` no tiene contraseña. Solo puedes entrar usando tu llave privada local.
*   **Acceso Web:** El servidor utiliza `ufw`. Cualquier intento de conexión directa al puerto 80 o 443 desde una IP que no sea de Cloudflare será rechazado.
*   **Persistencia:** Todos los datos residen en `/src/silverback/` para mantener la consistencia con tus `Makefiles`.
*   **Automatización:** El archivo `acme.json` de Traefik se pre-configura con permisos `600` para evitar errores de arranque de SSL.

### 🔑 Gestión de Llaves SSH (Acceso al Servidor)

El servidor **NO permite acceso por contraseña**. Solo es posible entrar mediante una pareja de llaves SSH (Pública/Privada).

#### A. ¿Ya tienes llaves SSH?
Si en tu terminal ya existen los archivos en `~/.ssh/` (ej: `id_ed25519.pub`), **no necesitas crear nuevas**. Simplemente ejecuta esto para ver tu llave pública:
```bash
cat ~/.ssh/id_ed25519.pub
```
Copia todo el texto que empieza por `ssh-ed25519 ...` y pégalo en tu `terraform.tfvars` en la variable `ssh_public_key`.

#### B. ¿No tienes llaves o quieres una exclusiva para el cliente?
Genera una nueva llave con este comando:
```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_remotemonkeys -C "despliegue-infra"
```
*   Esto creará dos archivos: `~/.ssh/id_remotemonkeys` (Privada: **¡NO COMPARTIR!**) y `~/.ssh/id_remotemonkeys.pub` (Pública).
*   Obtén el contenido de la pública:
    ```bash
    cat ~/.ssh/id_remotemonkeys.pub
    ```
*   Pega ese contenido en `terraform.tfvars`.

#### C. ¿Cómo conectar al servidor una vez desplegado?
Si usaste una llave con nombre personalizado (ej. `id_remotemonkeys`), debes conectar así:
```bash
ssh -i ~/.ssh/id_remotemonkeys root@<IP_DEL_SERVIDOR>
```
*Si usaste las llaves por defecto (`id_ed25519`), basta con:*
```bash
ssh root@<IP_DEL_SERVIDOR>
```

## 💡 Troubleshooting
*   **¿Problemas con subdominios?** Se utiliza la convención `prefijo-servicio` (ej: `t1-n8n.remotemonkeys.ai`) para máxima compatibilidad con Cloudflare SSL.
*   **¿Cambios en el servidor?** Si modificas el `cloud-init`, ten en cuenta que `terraform apply` no reiniciará el servidor automáticamente. Para cambios profundos, puedes recrear el nodo o ejecutar tus `Makefiles` de actualización manualmente.

### 🛠️ Instalación de Terraform (Ubuntu)

Para instalar Terraform en sistemas basados en Debian/Ubuntu, utilizaremos el repositorio oficial de HashiCorp. Sigue estos pasos exactamente en tu terminal:

#### 1. Preparar dependencias
```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
```

#### 2. Agregar la llave GPG de HashiCorp
```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

#### 3. Verificar la huella de la llave (Opcional, alta seguridad)
```bash
gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
```
*Deberías ver una huella que termina en `A3C4 F0F9 79CA A22C DB08 5062 1968 471B 5D63 D524`.*

#### 4. Agregar el repositorio de HashiCorp a tus fuentes
```bash
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
```

#### 5. Actualizar el índice de paquetes e instalar
**¡Este paso es vital para evitar el error "E: No se ha podido localizar el paquete":**
```bash
sudo apt-get update
sudo apt-get install terraform
```

#### 6. Verificar la instalación
```bash
terraform -version
```

---

### Nota sobre el error "E: No se ha podido localizar el paquete":
Si después de ejecutar `sudo apt-get update` sigues recibiendo el error de "no localizado", es posible que tu versión de Ubuntu sea muy nueva (o una versión de desarrollo) y el comando `$(lsb_release -cs)` esté devolviendo un nombre que no existe en los repositorios de HashiCorp.

**Si eso sucede:**
1. Reemplaza manualmente `$(lsb_release -cs)` en el comando del paso 4 por el nombre de una versión LTS compatible, como `jammy` (Ubuntu 22.04) o `noble` (Ubuntu 24.04).
2. Luego repite el paso 5.

