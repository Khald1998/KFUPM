# manage docker image to upload to ecr

resource docker_registry_image go_example {
  name = "${local.ecr_url}:v1"

  build {
    context    = "${path.module}/../app/."
    dockerfile = "Dockerfile"
    no_cache   = true
  }

  depends_on = [aws_ecr_repository.go_server]
}
resource aws_instance application {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.public.id]
  subnet_id                   = aws_subnet.main.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.profile.name

  user_data = <<EOF
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
EOF
#   user_data = file("run_this.sh")//iaac\ubuntu.sh

  depends_on = [aws_internet_gateway.gateway,docker_registry_image.go_example]
}

output application_ip {
  value       = aws_instance.application.public_ip
  description = "Application public IP"
}
