#!/bin/bash

apt-get update
apt-get install ca-certificates
apt-get install curl
apt-get install gnupg
apt-get install lsb-release
mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
echo ${password} | docker login --username=${user_name} --password-stdin ${repository_url}
docker pull ${format("%v/%v:%v", ecr_address, repository_name, image_tag)}
docker run -p 8080:8080 -d --restart always ${format("%v/%v:%v", ecr_address, repository_name, image_tag)}
