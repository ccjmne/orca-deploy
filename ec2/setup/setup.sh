#! /usr/bin/env bash

set -e

trap ctrl_c SIGINT
function ctrl_c {
  echo -e "\e[0m"
  exit 1
}

source ./utils.sh

trap 'catch $? $LINENO' ERR
catch() {
  ko "Error $1 occurred on line $2"
}

# Update installed packages
info "Updating installed packages..."
sudo yum update -y
ok "Installed packages updated successfully."

# Downloading Orca configuration file
options=$(aws s3 ls s3://orca-clients | awk '{ print substr($4, 1, index($4, ".conf") - 1) }')
info "Available client IDs:"
for opt in $options; do
  also "$opt"
done
ask "What is your client ID?" CLIENT_ID
saveenv CLIENT_ID
aws s3 cp "s3://orca-clients/$CLIENT_ID.conf" orca.conf.tpl
envsubst < orca.conf.tpl > orca.conf
ok "Configuration file downloaded successfully."

# Installing Docker
info "Installing Docker..."
sudo yum install -y docker
# Ensure current user belongs to 'docker' group
sudo usermod -a -G docker "$USER"
# Keep logs from growing too large
# See https://docs.docker.com/config/containers/logging/json-file/
sudo tee /etc/docker/daemon.json > /dev/null << EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m"
  }
}
EOF
sudo systemctl start docker.service
sudo systemctl enable docker
ok "Docker installed successfully."

# Installing NGINX
info "Installing NGINX..."
sudo yum install -y nginx
# Disable default server block, and increase server_names_hash_bucket_size to 64
sudo mv nginx.conf /etc/nginx/nginx.conf
# shellcheck disable=SC2016 # envsubst requires SHELL-FORMAT variables
# Avoid substituting nginx-specific variables, e.g. $http_host
# TODO: Consider using NGINX's official Docker image instead, which apparently accounts for this
envsubst '$CLIENT_ID' < nginx-default.conf.tpl | sudo tee /etc/nginx/conf.d/default.conf > /dev/null
sudo systemctl start nginx.service
sudo systemctl enable nginx.service
ok "NGINX installed successfully."

# Installing Let's Encrypt certificates
info "Installing Let's Encrypt certificates..."
sudo yum install -y certbot-nginx
envsubst < certbot.conf.tpl > certbot.conf
sudo certbot --nginx --config certbot.conf --non-interactive
sudo systemctl restart nginx.service
ok "Let's Encrypt certificates installed successfully."

# Setting up maintenance systemd timers
info "Setting up maintenance systemd timers..."
sudo mv systemd-timers/* /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now certbot-renew.timer
sudo systemctl enable --now yum-autoremove.timer
sudo systemctl enable --now journalctl-vacuum.timer
ok "Maintenance systemd timers set up successfully."

# Create swapfile
info "Setting up swap..."
if ! swapon -s | grep -q '/swapfile'; then
  sudo fallocate -l 2G /swapfile && sudo chmod 600 /swapfile
  sudo mkswap /swapfile && sudo swapon /swapfile
fi
# Automatically mount swapfile on boot
grep -q '/swapfile none swap sw 0 0' /etc/fstab || sudo tee -a /etc/fstab << EOF
/swapfile none swap sw 0 0
EOF
ok "Swap set up successfully."

# Set up motd
info "Setting up motd..."
sudo mv motd /etc/update-motd.d/00-header
sudo update-motd --force
ok "Message of the day set up successfully."
