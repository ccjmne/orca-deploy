#! /usr/bin/env bash
set -e

tmp=$(mktemp -d)
cd "$tmp"
wget "$(curl -s https://api.github.com/repos/ccjmne/orca-deploy/releases | grep browser_download_url | grep setup.tar.gz | head -n 1 | cut -d '"' -f 4)"
tar -zxvf setup.tar.gz
./setup.sh
mv -t ~ orca.conf html2pdf.conf update.sh utils.sh
cd - && rm -Rf "$tmp"
