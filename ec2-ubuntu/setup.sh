#!/bin/sh
set -e

export __OK='   [\033[0;32m ok \033[0m]'
export __KO='[\033[0;31m error \033[0m]'
export __NF=' [\033[1;34m info \033[0m]'

# Requires the ec2-orca-install IAM role to:
# - list the current instance's tags    from ec2
# - get client-specific configuration   from s3
# - access the Orca docker image        from ecr

printf "===============================================================================\n\
${__NF} Setting up Orca -- this will take a minute\
\n===============================================================================\n"

# Install message of the day w/ update instructions
cp ./motd /etc

# aws cli
apt-get update
apt-get install -y python-pip
pip install --upgrade awscli

# configure the CLIENT_ID environment variable using the "clientid" ec2 instance tag
aws ec2 describe-tags --filters "Name=resource-id,Values=`curl -s http://169.254.169.254/latest/meta-data/instance-id`" --region eu-west-1 > .ec2-instance-tags
apt-get install -y jq
export CLIENT_ID=`jq --raw-output ".Tags[] | select(.Key==\"clientid\") | .Value" .ec2-instance-tags`
echo "export CLIENT_ID=${CLIENT_ID}" > ~/.bash_profile
printf "===============================================================================\n\
${__NF} Setting up Orca for client: \033[1;34m${CLIENT_ID:?}\033[0m\
\n===============================================================================\n"

# configuration files
aws s3 cp s3://orca-clients/${CLIENT_ID}.conf orca.conf
sed -i *.conf -e "s/\${clientid}/${CLIENT_ID:?}/g"
printf "===============================================================================\n\
${__OK} Configuration files loaded\
\n===============================================================================\n"

# nginx
apt-get install -y nginx
cp nginx.conf /etc/nginx/conf.d/default.conf
printf "===============================================================================\n\
${__OK} NGINX installation completed\
\n===============================================================================\n"

# let's encrypt's certificates w/ certbot
# see https://certbot.eff.org/#ubuntuxenial-nginx
apt-get install -y software-properties-common
add-apt-repository -y ppa:certbot/certbot
apt-get update
apt-get install -y python-certbot-nginx
certbot --nginx --config certbot.conf --non-interactive
service nginx restart
printf "===============================================================================\n\
${__OK} Let's Encrypt certificates installed\
\n===============================================================================\n"

# docker
# see https://store.docker.com/editions/community/docker-ce-server-ubuntu
apt-get -y install apt-transport-https ca-certificates curl
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
	"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	$(lsb_release -cs) \
	stable"
apt-get update
apt-get -y install docker-ce

# set up auto-restart on crash for the docker daemon
systemctl enable docker.service
mkdir -p /etc/systemd/system/docker.service.d
cat > /etc/systemd/system/docker.service.d/override.conf <<EOF
[Service]
Restart=always
RestartSec=3
EOF

systemctl daemon-reload
printf "===============================================================================\n\
${__OK} Docker installation completed\
\n===============================================================================\n"

echo "
0  0    1 * *   root    apt-get autoremove
0  0    1 * *   root    journalctl --vacuum-time=10d" | tee -a /etc/crontab
service cron reload

printf "===============================================================================\n\
${__OK} Periodic cleanup tasks autocomated scheduled\
\n===============================================================================\n"

# create swap
# https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-ubuntu-16-04
fallocate -l 2G /swapfile && chmod 600 /swapfile
mkswap /swapfile && swapon /swapfile

# make the swap file permanent
cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab

# enable system for docker swap
# https://docs.docker.com/install/linux/linux-postinstall/#your-kernel-does-not-support-cgroup-swap-limit-capabilities
sed -re 's/^(GRUB_CMDLINE_LINUX)=.*$/\1="cgroup_enable=memory swapaccount=1"/' -i /etc/default/grub && update-grub

printf "===============================================================================\n\
${__OK} Memory swap file installed and enabled\
${__NF} System restart required. Run \e[2msudo shutdown -r now\e[0m\
\n===============================================================================\n"
