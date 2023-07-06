#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

echo "Make sure to have the web app available under the webapps/ directory."
read -p "Press Enter to continue..."

docker build -t orca:"$1" -t 424880512736.dkr.ecr.eu-west-1.amazonaws.com/orca:"$1" .
docker push 424880512736.dkr.ecr.eu-west-1.amazonaws.com/orca:"$1"
echo "Done."
