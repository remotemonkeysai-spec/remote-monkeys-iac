variable "server_name" { 
  type = string 
}

variable "server_type" { 
  type    = string 
  default = "cpx31" 
}

variable "location" { 
  type    = string 
  default = "ash" 
}

variable "ssh_public_key" { 
  type = string 
}