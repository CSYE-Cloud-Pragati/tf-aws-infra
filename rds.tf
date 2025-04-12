# Use a random string to make the parameter group name unique
resource "random_string" "db_param_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "random_id" "rds_suffix" {
  byte_length = 4
}

# DB Parameter Group
resource "aws_db_parameter_group" "app_db_param_group" {
  name   = "app-db-param-group-${random_id.rds_suffix.hex}"
  family = "postgres17"
}

# DB Subnet Group
resource "aws_db_subnet_group" "private_subnet_group" {
  name       = "private-subnet-groupname-${random_id.rds_suffix.hex}"
  subnet_ids = [for subnet in aws_subnet.private_subnet : subnet.id]
}

resource "random_password" "db_pass" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "db_pass" {
  name                    = "db_password_secret"
  kms_key_id              = aws_kms_key.secrets_key.arn
  recovery_window_in_days = 0

}

resource "aws_secretsmanager_secret_version" "db_password_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_pass.id
  secret_string = jsonencode({ password = random_password.db_pass.result }) // Ensure var.db_password is stored securely as sensitive
}


# DB Instance
resource "aws_db_instance" "app_db" {
  identifier             = "csye6225"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "17"
  instance_class         = "db.t3.micro" # Cheapest option
  username               = var.db_username
  password               = random_password.db_pass.result
  db_name                = var.db_name
  parameter_group_name   = aws_db_parameter_group.app_db_param_group.name
  db_subnet_group_name   = aws_db_subnet_group.private_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_security_group.id]
  publicly_accessible    = false
  multi_az               = false
  skip_final_snapshot    = true
  storage_encrypted      = true
  kms_key_id             = aws_kms_key.rds_key.arn
}

