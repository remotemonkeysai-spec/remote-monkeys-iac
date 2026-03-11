# Firewall estricto (Reduciendo la superficie de ataque)
resource "hcloud_firewall" "silverback_fw" {
  name = "${var.server_name}-firewall"

  # Permitir SSH 
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips =["0.0.0.0/0", "::/0"]
  }

  # Permitir HTTP (Traefik)
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "80"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  # Permitir HTTPS (Traefik)
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "443"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
}