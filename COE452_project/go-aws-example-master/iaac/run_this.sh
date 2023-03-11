#!/bin/bash
sudo apt-get update
sudo apt-get install -y pt-transport-https ca-certificates curl gnupg lsb-release software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu `lsb_release -cs` test"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo gpasswd -a $USER docker
newgrp docker

echo ${data.aws_ecr_authorization_token.go_server.password} | docker login --username=${data.aws_ecr_authorization_token.go_server.user_name} --password-stdin ${aws_ecr_repository.go_server.repository_url}

docker run -p ${local.application_port}:${local.application_internal_port} -d --restart always ${docker_registry_image.go_example.name}
