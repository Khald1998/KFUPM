output "rds_hostname" {
    description = "RDS instance hostname"
    value       = aws_db_instance.main.address
    sensitive   = false
}
output "rds_endpoint" {
    description = "RDS endpoint"
    value       = aws_db_instance.main.endpoint
    sensitive   = false
}
output "rds_port" {
    description = "RDS instance port"
    value       = aws_db_instance.main.port
    sensitive   = false
}

output "rds_username" {
    description = "RDS instance root username"
    value       = aws_db_instance.main.username
    sensitive   = false
}
output "rds_password" {
    description = "RDS instance root username"
    value       = nonsensitive(aws_db_instance.main.password)
    sensitive   = false

}
output "ec2_dns" {
    description = "Public dns name of ec2"
    value       = aws_instance.main.public_dns
    sensitive   = false
}