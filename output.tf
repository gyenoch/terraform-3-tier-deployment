#Alb ARN for user access on the web
output "lb-dns-name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.application-load-balancer.dns_name
}

#output the rds endpoint to aid in CLI access of database
output "db_endpoint" {
  value = aws_db_instance.database-instance.endpoint
}

# Obtain the DB password locally in a txt file
resource "local_sensitive_file" "rds-db-password" {
  filename = "${path.module}/${var.rds-username-file}"
  content  = local.db_credentials.password
}

# Obtain the DB username locally in a txt file
resource "local_sensitive_file" "db-username" {
  filename = "${path.module}/${var.rds-password-file}"
  content  = local.db_credentials.username
}

resource "local_sensitive_file" "db-credential" {
  filename = "${path.module}/${var.rds-credential-file}"
  content  = data.aws_secretsmanager_secret_version.current.secret_string
}