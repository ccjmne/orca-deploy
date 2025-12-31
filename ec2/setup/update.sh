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
  also "Please log out and log back in for the changes to take effect."
  also "Once your session is resumed, please run this script once more."
  exit 1
fi

info "Updating Orca to $(say "orca:$TAG" cyan)..."

ecr=424880512736.dkr.ecr.eu-west-1.amazonaws.com

aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin $ecr

docker pull "$ecr/orca:$TAG"
docker stop html2pdf || true && (docker rm html2pdf || true)
docker run -it -d                  \
    --name=html2pdf                \
    --restart=unless-stopped       \
    --publish=3000:3000            \
    --memory=350M --memory-swap=1G \
    --env-file html2pdf.conf       \
    ghcr.io/ccjmne/puppeteer-html2pdf:latest
docker stop orca || true && (docker rm orca || true)
docker run -it -d                 \
    --name=orca                   \
    --restart=unless-stopped      \
    --publish=8080:8080           \
    --memory=96M --memory-swap=1G \
    --env-file=orca.conf          \
    "$ecr/orca:$TAG"

ok "Orca updated successfully."
info "Available at: $(say "https://$CLIENT_ID.orca-solution.com" cyan)"
