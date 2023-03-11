resource "aws_db_instance" "main" {
    engine               = "mysql"
    engine_version       = "8.0.27"
    identifier = "maindb"
    username                  = "username"
    password                  = "password"
    instance_class            = "db.t2.micro"
    storage_type = "gp2"
    allocated_storage     = 10
    max_allocated_storage = 20
    db_subnet_group_name = aws_db_subnet_group.main.id
    vpc_security_group_ids = [aws_security_group.open_door.id]
    skip_final_snapshot = true
    publicly_accessible = false
    allow_major_version_upgrade = true
}

resource "aws_db_subnet_group" "main" {
  name       = "subnet group for rds"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "subnet group for rds"
  }
}