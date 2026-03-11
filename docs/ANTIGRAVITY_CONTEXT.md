# Contexto del Proyecto: Infrastructure as Code (Remote Monkeys)

## Resumen
Monorepo de infraestructura que gestiona el aprovisionamiento de servidores Hetzner para clientes B2B.

## Estructura
- `/modules/silverback`: Módulo central.
  - `main.tf`: Recurso `hcloud_server` (CPX31), `hcloud_firewall` (SSH, 80, 443).
  - `dns.tf`: Gestión de registros DNS en Cloudflare (Prefijo-servicio).
  - `templates/cloud-init.yaml.tpl`: Script de bootstrapping (Docker, UFW, apt, kernel tuning).
- `/environments/`: Implementaciones específicas por cliente.

## Reglas de Arquitectura
1. Terraform aprovisiona "el terreno" (Servidor, Firewall, Red, DNS).
2. Los Makefiles (fuera de este repo, en el código de la App) gestionan "la casa" (Contenedores, configuración de apps).
3. Todo tráfico entra vía Cloudflare (Proxy=true) y se filtra por `ufw` en el servidor.
4. Nomenclatura subdominios: `prefijo-servicio.remotemonkeys.ai`.