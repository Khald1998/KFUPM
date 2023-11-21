# # ########
# # Docker 
# # ########



# resource "aws_ecr_repository" "main" {
#   name                 = var.repository_name
#   image_tag_mutability = "IMMUTABLE"
#   force_delete         = true

#   image_scanning_configuration {
#     scan_on_push = true
#   }
# }

# data "aws_ecr_authorization_token" "main" {
# }



# resource "docker_image" "helloworld" {
#   name          = local.ecr_image_name
#   # keep_remotely = 

#   build {
#     context    = "${path.module}/Backend/."
#     dockerfile = "Dockerfile"
#     no_cache   = true
#   }


# }


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
    Name = "HelloWorld"
  }
}
