#!/bin/bash -xe
apt-get update && apt install -y nginx
systemctl enable nginx
systemctl start nginx