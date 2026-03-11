output "ipv4_address" {
  value       = hcloud_server.silverback_node.ipv4_address
  description = "IP pública del servidor recién creado"
}