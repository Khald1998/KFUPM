# ########
# VPC 
# ########
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block  # defines the CIDR block for the VPC
  enable_dns_hostnames = true                # enables DNS hostnames in the VPC
  enable_dns_support   = true                # enables DNS support in the VPC

  tags = {                                   
    Name = var.vpc_name                      # assigns a name tag to the VPC
  }
}

# ########
# internet gateway 
# ########
resource "aws_internet_gateway" "main" {

  vpc_id = aws_vpc.main.id                    # associates the internet gateway with the VPC

  tags = {
    Name = "internet gateway"                 # assigns a name tag to the internet gateway
  }
}

# ########
# subnet 
# ########
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id    # associates the subnet with the VPC
  cidr_block              = var.subnet_cidr_block  # defines the CIDR block for the subnet
  map_public_ip_on_launch = true              # associates a public IP address with instances launched in the subnet

  tags = {
    Name = "public-1"                        # assigns a name tag to the subnet
  }
}

# creates a route table for the VPC and adds a default route to the internet gateway
resource "aws_route_table" "main_route" {
  vpc_id = aws_vpc.main.id                    # associates the route table with the VPC

  route {
    cidr_block = "0.0.0.0/0"                  # defines the destination CIDR block for the default route
    gateway_id = aws_internet_gateway.main.id # defines the gateway for the default route
  }
}

# associates the subnet with the route table
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.public_1.id    # associates the subnet with the route table
  route_table_id = aws_route_table.main_route.id  # associates the route table with the subnet
}

# ########
# security group 
# ########

resource "aws_security_group" "instance" {
  name   = "shh"                              # assigns a name to the security group
  vpc_id = aws_vpc.main.id                     # associates the security group with the VPC

  # allows inbound traffic to port 22, 80, and 8080
  ingress { //shh
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { 
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress { 
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allows outbound traffic to all destinations
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



# ########
# EC2 
# ########
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

resource "aws_instance" "main" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_1.id
  vpc_security_group_ids      = [aws_security_group.instance.id]
  key_name                    = "main_key"
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  user_data = templatefile("${path.module}/user_data.sh", {
    ecr_address    = local.ecr_address
    repository_name = var.repository_name
    image_tag       = local.image_tag
    password        = data.aws_ecr_authorization_token.main.password
    user_name       = data.aws_ecr_authorization_token.main.user_name
    repository_url  = aws_ecr_repository.main.repository_url
  })

  tags = {
    Name = var.EC2_name
  }

}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"

  assume_role_policy = file("${path.module}/ec2_role.json")

  tags = {
    project = "ec2_role"
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role_policy" "ec2_policy" {
  name = "ec2_policy"
  role = aws_iam_role.ec2_role.id
  policy = file("${path.module}/ec2_policy.json")
}


resource "aws_ecr_repository" "main" {
  name                 = var.repository_name
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}
data "aws_ecr_authorization_token" "main" {}