#!/bin/bash

export HTTP_PROXY=http://${SQUID_IP}:3128
export HTTPS_PROXY=http://${SQUID_IP}:3128

yum update -y
yum install -y httpd

systemctl enable --now httpd

cat /etc/hostname | sudo tee /var/www/html/index.html

exit