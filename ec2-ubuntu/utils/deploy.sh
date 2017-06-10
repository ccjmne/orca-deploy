#!/bin/sh
set -e

mkdir __tmp && cd __tmp
wget `curl -s https://api.github.com/repos/ccjmne/orca-deploy/releases | grep browser_download_url | grep setup.tar.gz | head -n 1 | cut -d '"' -f 4` && tar -zxvf setup.tar.gz
sed -i *.sh -e 's/\r$//' && chmod +x *.sh && ./setup.sh
mv orca.conf .. && mv update.sh ..
cd - && rm -Rf __tmp
