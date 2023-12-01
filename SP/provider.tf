terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    docker = {
      source  = "kreuzwerker/docker"
      # version = ">= 2.12, < 3.0" //docker latest version is broken
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
    }

  }
}
# provider "aws" {
# }

provider "docker" {
  registry_auth {
    address  = local.ecr_address
    username = data.aws_ecr_authorization_token.main.user_name
    password = data.aws_ecr_authorization_token.main.password
  }
}