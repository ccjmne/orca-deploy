#!/bin/sh
set -e

# Environment must be setup beforehand using setup.sh

# Requires the ec2-orca-install IAM role to:
# - access the Orca docker image			from ecr

printf "===============================================================================\n\
  Updating Orca...\
\n===============================================================================\n"

sudo `aws ecr get-login --no-include-email --region eu-west-1`
sudo docker stop orca || true && sudo docker rm orca || true
sudo docker pull 424880512736.dkr.ecr.eu-west-1.amazonaws.com/orca:latest
sudo docker run -it -d --memory=420m --restart=on-failure:2 -p=8080:8080 --name=orca --env-file orca.conf 424880512736.dkr.ecr.eu-west-1.amazonaws.com/orca:latest

printf "===============================================================================\n\
  All done. Servers are up and running.\
\n===============================================================================\n"
