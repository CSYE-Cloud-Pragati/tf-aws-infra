# IAM Resources for EC2 S3 Access
data "aws_caller_identity" "current" {}
# IAM Role for EC2 S3 access.
resource "aws_iam_role" "ec2_s3_access_role" {
  name = "ec2_s3_access_role"

  # Trust policy that allows EC2 instances to assume this role.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

# IAM Policy that allows EC2 instances to access the S3 bucket.
resource "aws_iam_policy" "s3_access_policy" {
  name        = "s3_access_policy"
  description = "Policy for EC2 to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:PutObjectVersionAcl",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.app_bucket.arn,
          "${aws_s3_bucket.app_bucket.arn}/*"
        ]
      }
    ]
  })
}

# Attach the S3 access policy to the EC2 S3 access role.
resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  role       = aws_iam_role.ec2_s3_access_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# Create an instance profile for EC2 using the S3 access role.
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_s3_profile"
  role = aws_iam_role.ec2_s3_access_role.name
}

# Attach CloudWatch permissions to the existing EC2 S3 Access Role.
resource "aws_iam_role_policy_attachment" "cw_policy_attachment_to_ec2_s3" {
  role       = aws_iam_role.ec2_s3_access_role.name
  policy_arn = aws_iam_policy.cloudwatch_agent_policy.arn
}

# IAM Resources for CloudWatch Agent

# IAM Role for the CloudWatch Agent to publish logs and metrics.
resource "aws_iam_role" "cloudwatch_agent_role" {
  name = "cloudwatch_agent_role"

  # Trust policy that allows EC2 instances to assume this role.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.common_tags
}

# IAM Policy granting permissions for the CloudWatch Agent.
resource "aws_iam_policy" "cloudwatch_agent_policy" {
  name        = "cloudwatch_agent_policy"
  description = "Policy to allow CloudWatch Agent to send logs and metrics"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutRetentionPolicy"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach the CloudWatch Agent policy to its role.
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy_attachment" {
  role       = aws_iam_role.cloudwatch_agent_role.name
  policy_arn = aws_iam_policy.cloudwatch_agent_policy.arn
}

# Create an instance profile for the CloudWatch Agent.
resource "aws_iam_instance_profile" "cloudwatch_agent_instance_profile" {
  name = "cloudwatch_agent_profile"
  role = aws_iam_role.cloudwatch_agent_role.name
}

resource "aws_iam_policy" "ec2_kms_policy" {
  name        = "EC2KMSUsagePolicy"
  description = "Policy allowing EC2 resources to use the EC2 KMS key for encryption and decryption"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "EC2KMSUsage",
        Effect : "Allow",
        Action : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource : aws_kms_key.ec2_key.arn
      }
    ]
  })
}

# RDS KMS Policy
resource "aws_iam_policy" "rds_kms_policy" {
  name        = "RDSKMSUsagePolicy"
  description = "Policy allowing RDS to use the RDS KMS key for encryption and decryption"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "RDSKMSUsage",
        Effect : "Allow",
        Action : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource : aws_kms_key.rds_key.arn
      }
    ]
  })
}

# S3 KMS Policy
resource "aws_iam_policy" "s3_kms_policy" {
  name        = "S3KMSUsagePolicy"
  description = "Policy allowing S3 to use the S3 KMS key for encryption and decryption"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "S3KMSUsage",
        Effect : "Allow",
        Action : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource : aws_kms_key.s3_key.arn
      }
    ]
  })
}

# Secrets Manager KMS Policy
resource "aws_iam_policy" "secrets_kms_policy" {
  name        = "SecretsKMSUsagePolicy"
  description = "Policy granting permissions to decrypt secrets and encrypt using the Secrets Manager KMS key"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "SecretsKMSUsage",
        Effect : "Allow",
        Action : [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource : aws_kms_key.secrets_key.arn
      },
      {
        Sid : "SecretsManagerAccess",
        Effect : "Allow",
        Action : [
          "secretsmanager:CreateSecret",
          "secretsmanager:DeleteSecret",
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutResourcePolicy",
          "secretsmanager:PutSecretValue",
          "secretsmanager:RestoreSecret",
          "secretsmanager:TagResource",
          "secretsmanager:UntagResource",
          "secretsmanager:UpdateSecret"
        ],
        Resource : aws_secretsmanager_secret.db_pass.arn
      }
    ]
  })
}

# Attach the Secrets Manager KMS Policy to the EC2 role
resource "aws_iam_role_policy_attachment" "attach_secrets_kms_policy" {
  role       = aws_iam_role.ec2_s3_access_role.name
  policy_arn = aws_iam_policy.secrets_kms_policy.arn
}

resource "aws_secretsmanager_secret_policy" "db_password_policy" {
  secret_arn = aws_secretsmanager_secret.db_pass.arn

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "AllowRootAndEC2Access",
        Effect : "Allow",
        Principal : {
          AWS : [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.ec2_s3_access_role.name}"
          ]
        },
        Action : [
          "secretsmanager:CreateSecret",
          "secretsmanager:DeleteSecret",
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutResourcePolicy",
          "secretsmanager:PutSecretValue",
          "secretsmanager:RestoreSecret",
          "secretsmanager:TagResource",
          "secretsmanager:UntagResource",
          "secretsmanager:UpdateSecret"
        ],
        Resource : "*"
      },
      {
        Sid : "DenyNonApprovedAccess",
        Effect : "Deny",
        Principal : "*",
        Action : [
          "secretsmanager:CreateSecret"
        ],
        Resource : "*",
        Condition : {
          StringNotEquals : {
            "aws:PrincipalArn" : [
              "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
              "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.ec2_s3_access_role.name}"
            ]
          }
        }
      }
    ]
  })
}