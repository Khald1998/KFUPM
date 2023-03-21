variable "vpc_name" {
  type    = string
  default = "main VPC"
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  type    = string
  default = "10.0.0.0/24"
}

variable "EC2_name" {
  type    = string
  default = "web-app"
}
variable "repository_name" {
  type    = string
  default = "my_repository"
}