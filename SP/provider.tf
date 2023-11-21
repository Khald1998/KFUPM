terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    docker = {
      source  = "kreuzwerker/docker"
      # version = ">= 2.12, < 3.0" //docker latest version is broken
    }
  }
}
# provider "aws" {
# }

provider "docker" {

}