#!/bin/sh
set -e

export __OK='   [\033[0;32m ok \033[0m]'
export __KO='[\033[0;31m error \033[0m]'
export __NF=' [\033[1;34m info \033[0m]'

# Environment must be set up beforehand, using setup.sh

# Requires the ec2-orca-install IAM role to:
# - access the Orca docker image			from ecr

if [ $# -eq 0 ]; then
  TAG="latest"
else
  TAG="$1"
fi

printf "===============================================================================\n\
${__NF} Updating Orca to \033[1;97morca:${TAG}\033[0m\n\
===============================================================================\n"

sudo `aws ecr get-login --no-include-email --region eu-west-1`
sudo docker pull 424880512736.dkr.ecr.eu-west-1.amazonaws.com/orca:$TAG
sudo docker stop html2pdf || true && sudo docker rm html2pdf || true
sudo docker run -it -d --restart=unless-stopped -p=3000:3000 --memory=200M --memory-swap=1G --name=html2pdf 424880512736.dkr.ecr.eu-west-1.amazonaws.com/puppeteer-html2pdf:latest
sudo docker stop orca || true && sudo docker rm orca || true
sudo docker run -it -d --restart=unless-stopped -p=8080:8080 --memory=200M --memory-swap=1G --name=orca --env-file orca.conf 424880512736.dkr.ecr.eu-west-1.amazonaws.com/orca:$TAG

printf "===============================================================================\n\
${__OK} All done. Servers are up and running.\n\
${__NF} Available at: \033[4;97mhttps://\033[1;34m${CLIENT_ID}\033[0;4;97m.orca-solution.com\033[0m\
\n===============================================================================\n"
