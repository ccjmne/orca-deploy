#!/bin/sh
set -e

# Requires the ec2-orca-install IAM role to:
# - list the current instance's tags		from ec2
# - get client-specific configuration		from s3
# - access the Orca docker image			from ecr

printf "===============================================================================\n\
  Setting up Orca -- this will take a minute\
\n===============================================================================\n"

# aws cli
sudo apt-get update
sudo apt-get install -y python-pip
sudo pip install --upgrade awscli

# configure the clientid environment variable using the "clientid" ec2 instance tag
aws ec2 describe-tags --filters "Name=resource-id,Values=`curl -s http://169.254.169.254/latest/meta-data/instance-id`" --region eu-west-1 > .ec2-instance-tags
sudo apt-get install -y jq
export clientid=`jq --raw-output ".Tags[] | select(.Key==\"clientid\") | .Value" .ec2-instance-tags`
printf "===============================================================================\n\
  Setting up Orca for client: ${clientid:?}\
\n===============================================================================\n"

# configuration files
aws s3 cp s3://orca-clients/${clientid}.conf orca.conf
sed -i *.conf -e "s/\${clientid}/${clientid:?}/g"
printf "===============================================================================\n\
  Configuration files loaded\
\n===============================================================================\n"

# nginx
sudo apt-get install -y nginx
sudo cp nginx.conf /etc/nginx/conf.d/default.conf
printf "===============================================================================\n\
  NGINX installation completed\
\n===============================================================================\n"

# let's encrypt's certificates w/ certbot
# see https://certbot.eff.org/#ubuntuxenial-nginx
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:certbot/certbot
sudo apt-get update
sudo apt-get install -y python-certbot-nginx
sudo certbot --nginx --config certbot.conf --non-interactive
sudo service nginx restart
printf "===============================================================================\n\
  Let's Encrypt certificates installed\
\n===============================================================================\n"

# docker
# see https://store.docker.com/editions/community/docker-ce-server-ubuntu
sudo apt-get -y install apt-transport-https ca-certificates curl
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"
sudo apt-get update
sudo apt-get -y install docker-ce
printf "===============================================================================\n\
  Docker installation completed\
\n===============================================================================\n"

# orca
sudo `aws ecr get-login --no-include-email --region eu-west-1`
sudo docker stop orca || true && sudo docker rm orca || true
sudo docker pull 424880512736.dkr.ecr.eu-west-1.amazonaws.com/orca:latest
sudo docker run -it -d --memory=420m --restart=on-failure:2 -p=8080:8080 --name=orca --env-file orca.conf 424880512736.dkr.ecr.eu-west-1.amazonaws.com/orca:latest

printf "===============================================================================\n\
  All done. Servers are up and running.\
\n===============================================================================\n"
