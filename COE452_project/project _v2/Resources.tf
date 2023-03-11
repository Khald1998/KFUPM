data "aws_region" "main" {}
data "archive_file" "lambda-functions" {
    type = "zip"
    source_dir  = "./Lambda-Functions"
    output_path = "./Lambda-Functions.zip"
}
data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

  owners           = ["099720109477"]
}
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}