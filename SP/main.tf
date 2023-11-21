# ########
# VPC 
# ########
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.vpc_name
  }
}
# ########
# internet gateway 
# ########
resource "aws_internet_gateway" "main" {

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "internet gateway"
  }
}
# ########
# subnet 
# ########
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-1"
  }
}


resource "aws_route_table" "main_route" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

}
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.main_route.id
}

# ########
# security group 
# ########


resource "aws_security_group" "instance" {
  name   = "shh"
  vpc_id = aws_vpc.main.id

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# ########
# Docker 
# ########



resource "aws_ecr_repository" "main" {
  name                 = var.repository_name
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

data "aws_ecr_authorization_token" "main" {
}



resource "docker_image" "backend" {
  name          = local.ecr_image_name
  build {
    context    = "${path.module}/Backend/."
    dockerfile = "Dockerfile"
    no_cache   = true
  }
}

resource "docker_registry_image" "backend" {
  name          = docker_image.backend.name
  keep_remotely = true
}

# ########
# run container 
# ########
data "aws_caller_identity" "current" {}

resource "aws_ecs_cluster" "demo-ecs-cluster" {
  name = "ecs-cluster-backend"
}



resource "aws_ecs_task_definition" "demo-ecs-task-definition" {
  family                   = "ecs-task-definition-demo"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = "1024"
  cpu                      = "512"
  execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"
  container_definitions    = jsonencode([{
    name      = "demo-container",
    image     = aws_ecr_repository.main.repository_url,
    memory    = 1024,
    cpu       = 512,
    essential = true,
    entryPoint = ["python"],
    command    = ["app.py"],
    portMappings = [{
      containerPort = 8080,
      hostPort      = 8080
    }]
  }])


}


# resource "aws_ecs_service" "demo-ecs-service" {
#   name            = "backend-app"
#   cluster         = aws_ecs_cluster.demo-ecs-cluster.id
#   task_definition = aws_ecs_task_definition.demo-ecs-task-definition.arn
#   launch_type     = "FARGATE"
#   network_configuration {
#     subnets          = [aws_subnet.public_1.id]
#     assign_public_ip = true
#   }
#   desired_count = 1
# }

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
