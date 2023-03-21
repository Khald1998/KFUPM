
resource "time_static" "now" {}

locals {
  ecr_address    = replace(data.aws_ecr_authorization_token.main.proxy_endpoint, "https://", "")
  image_tag      = "build-${time_static.now.unix}"
  ecr_image_name = format("%v/%v:%v", local.ecr_address, var.repository_name, local.image_tag)

}

