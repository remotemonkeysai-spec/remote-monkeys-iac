# Registrar tu llave SSH en Hetzner
resource "hcloud_ssh_key" "silverback_key" {
  name       = "${var.server_name}-ssh-key"
  public_key = var.ssh_public_key
}