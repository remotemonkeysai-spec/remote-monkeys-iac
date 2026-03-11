variable "hcloud_token" { 
  type      = string
  sensitive = true 
}

variable "cloudflare_api_token" { 
  type      = string
  sensitive = true 
}

variable "ssh_public_key" { 
  type = string 
}

variable "cloudflare_zone_id" { 
  type = string 
}