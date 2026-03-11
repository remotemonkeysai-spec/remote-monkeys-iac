module "silverback_node" {
  # Apuntamos a la ruta local donde vive tu módulo
  source = "../../modules/silverback"

  # Nomenclatura coherente con el cliente
  server_name        = "vps-t1-prod"
  subdomain_prefix   = "t1" # Esto generará: t1-n8n.remotemonkeys.ai, t1-app.remotemonkeys.ai, etc.
  
  # Configuración de hardware y ubicación
  server_type        = "cpx31"
  location           = "ash" 
  
  # Credenciales (se leen desde variables.tf -> terraform.tfvars)
  ssh_public_key     = var.ssh_public_key
  cloudflare_zone_id = var.cloudflare_zone_id
}

# Output para ver la IP al finalizar
output "ip_publica_t1" {
  value       = module.silverback_node.ipv4_address
  description = "IP Pública del servidor para el cliente t1"
}