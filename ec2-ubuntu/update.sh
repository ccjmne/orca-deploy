#!/bin/sh
set -e

export __OK='   [\033[0;32m ok \033[0m]'
export __KO='[\033[0;31m error \033[0m]'
export __NF=' [\033[1;34m info \033[0m]'

# Environment must be setup beforehand, using setup.sh

# Requires the ec2-orca-install IAM role to:
# - access the Orca docker image			from ecr

printf "===============================================================================\n\
${__NF} Updating Orca...\
\n===============================================================================\n"

sudo `aws ecr get-login --no-include-email --region eu-west-1`
sudo docker stop orca || true && sudo docker rm orca || true
sudo docker pull 424880512736.dkr.ecr.eu-west-1.amazonaws.com/orca:latest
sudo docker run -it -d --memory=420m --restart=on-failure:2 -p=8080:8080 --name=orca --env-file orca.conf 424880512736.dkr.ecr.eu-west-1.amazonaws.com/orca:latest

printf "===============================================================================\n\
${__OK} All done. Servers are up and running.\
\n===============================================================================\n"
