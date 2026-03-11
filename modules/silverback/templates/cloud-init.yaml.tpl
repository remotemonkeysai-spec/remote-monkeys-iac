#cloud-config
package_update: true
package_upgrade: true

packages:
  - curl
  - git
  - htop
  - make
  - ufw
  - apt-transport-https
  - ca-certificates
  - gnupg
  - lsb-release

ssh_pwauth: false

runcmd:
  # 1. Seguridad SSH inicial
  - sed -i 's/^#PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
  - sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
  - systemctl restart sshd

  # 2. Docker Engine (Instalación nativa)
  - curl -fsSL https://get.docker.com -o get-docker.sh
  - sh get-docker.sh
  - systemctl enable docker
  - systemctl start docker

  # 3. Firewall (UFW) - Solo Cloudflare + SSH
  - ufw default deny incoming
  - ufw default allow outgoing
  - ufw allow 22/tcp
  - curl -s https://www.cloudflare.com/ips-v4 -o /tmp/cf_ips
  - while read ip; do ufw allow from $ip to any port 80,443 proto tcp; done < /tmp/cf_ips
  - ufw --force enable

  # 4. Carpeta base para tu monorepo
  - mkdir -p /src/silverback
  
  # 5. Marcador de aprovisionamiento completado
  - touch /src/silverback/.provisioning_done