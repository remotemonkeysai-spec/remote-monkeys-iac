terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.45.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 4.0.0"
    }
  }
}

# Creación del Servidor (VPS)
resource "hcloud_server" "silverback_node" {
  name         = var.server_name
  image        = "ubuntu-24.04"
  server_type  = var.server_type
  location     = var.location
  
  ssh_keys     = [hcloud_ssh_key.silverback_key.id]
  firewall_ids = [hcloud_firewall.silverback_fw.id]
  backups      = true 

  user_data = templatefile("${path.module}/templates/cloud-init.yaml.tpl", {})

  lifecycle {
    ignore_changes = [user_data]
  }
}