variable "cloudflare_zone_id" { type = string }
variable "subdomain_prefix" { type = string }

# Registros DNS
resource "cloudflare_dns_record" "n8n" {
  zone_id = var.cloudflare_zone_id
  name    = "${var.subdomain_prefix}-n8n"
  content = hcloud_server.silverback_node.ipv4_address
  type    = "A"
  proxied = true
  ttl     = 1
}

resource "cloudflare_dns_record" "app" {
  zone_id = var.cloudflare_zone_id
  name    = "${var.subdomain_prefix}-app"
  content = hcloud_server.silverback_node.ipv4_address
  type    = "A"
  proxied = true
  ttl     = 1
}

resource "cloudflare_dns_record" "api" {
  zone_id = var.cloudflare_zone_id
  name    = "${var.subdomain_prefix}-api"
  content = hcloud_server.silverback_node.ipv4_address
  type    = "A"
  proxied = true
  ttl     = 1
}

# Configuración de SSL (Sintaxis v5 correcta: singular)
resource "cloudflare_zone_setting" "ssl_mode" {
  zone_id = var.cloudflare_zone_id
  setting_id = "ssl"
  value      = "full"
}