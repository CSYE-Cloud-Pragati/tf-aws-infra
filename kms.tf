resource "aws_kms_key" "ec2_key" {
  description             = "KMS key for encrypting EC2 resources"
  deletion_window_in_days = 7
  rotation_period_in_days = 90
  enable_key_rotation     = true
  multi_region            = true
}

resource "aws_kms_key" "rds_key" {
  description             = "KMS key for encrypting RDS resources"
  deletion_window_in_days = 7
  rotation_period_in_days = 90
  enable_key_rotation     = true
  multi_region            = true
}

resource "aws_kms_key" "s3_key" {
  description             = "KMS key for encrypting S3 bucket contents"
  deletion_window_in_days = 7
  rotation_period_in_days = 90
  enable_key_rotation     = true
  multi_region            = true
}

resource "aws_kms_key" "secrets_key" {
  description             = "KMS key for encrypting Secrets Manager secrets"
  deletion_window_in_days = 7
  rotation_period_in_days = 90
  enable_key_rotation     = true
  multi_region            = true
}
