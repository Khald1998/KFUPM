terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # version = "4.0.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      # version = "2.19.2"
    }
    random = {
      source  = "hashicorp/random"
      # version = "3.1.0"
    }
  }
}
provider "cloudflare" {
  email = "arraaa1999@gmail.com"
  api_key = "0f25b548092a4bedfb2b9bb52feb86165e54a"
}
provider "aws" {
  region = "us-east-1"
}
