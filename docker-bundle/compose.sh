#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

echo "Make sure to have the web app available under the webapps/ directory."
read -rp "Press Enter to continue..."

ecr=424880512736.dkr.ecr.eu-west-1.amazonaws.com

aws ecr get-login-password | docker login --username AWS --password-stdin $ecr
docker buildx use multiarch || docker buildx create --use --name multiarch --platform amd64,arm64
docker buildx build --platform amd64,arm64 --tag $ecr/orca:"$1" --push .
echo "Done."
