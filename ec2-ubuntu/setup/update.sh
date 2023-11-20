#! /usr/bin/env bash
set -e

# The environment must be set up beforehand, using setup.sh

# Requires the ec2-orca-install IAM role to:
# - access the Orca docker image			from ecr

if [ $# -eq 0 ]; then
  TAG="latest"
else
  TAG="$1"
fi

source ./utils.sh

# Ensure current user belongs to 'docker' group
if ! id --groups --name --zero | grep --null-data --line-regexp --quiet docker
then
  sudo usermod -a -G docker "$USER"
  info "The current user has been added to the 'docker' group."
  also "After your session is reloaded, please run this script once more."
  read -re -n 1 -p "$(also "Press any key to reload your session...")"
  relog
fi

info "Updating Orca to $(say "orca:$TAG" white)..."

ecr=424880512736.dkr.ecr.eu-west-1.amazonaws.com

aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin $ecr

sudo docker pull "$ecr/orca:$TAG"
sudo docker stop html2pdf || true && (sudo docker rm html2pdf || true)
sudo docker run -it -d --restart=unless-stopped -p=3000:3000 --memory=200M --memory-swap=1G --name=html2pdf ghcr.io/ccjmne/puppeteer-html2pdf:latest
sudo docker stop orca || true && (sudo docker rm orca || true)
sudo docker run -it -d --restart=unless-stopped -p=8080:8080 --memory=200M --memory-swap=1G --name=orca --env-file orca.conf "$ecr/orca:$TAG"

ok "Orca updated successfully."
info "Available at: $(say "https://$CLIENT_ID.orca-solution.com" white)"
