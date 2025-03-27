###############################################################
# iam.tf
# This file contains IAM roles, policies, and instance profiles 
# for your EC2 instance. It includes:
#
# 1. Resources for S3 access.
# 2. Resources for the CloudWatch Agent (to enable logging and metrics).
#
# Do not remove any existing declarations to avoid errors.
###############################################################

###############################
# Section 1: IAM Resources for EC2 S3 Access
###############################

# IAM Role for EC2 S3 access.
resource "aws_iam_role" "ec2_s3_access_role" {
  name = "ec2_s3_access_role"

  # Trust policy that allows EC2 instances to assume this role.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
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

# NEW: Attach CloudWatch permissions to the existing EC2 S3 Access Role.
# This ensures that the role has permissions for logs and metrics:
# logs:CreateLogGroup, logs:CreateLogStream, logs:PutLogEvents, logs:DescribeLogStreams,
# and cloudwatch:PutMetricData.
resource "aws_iam_role_policy_attachment" "cw_policy_attachment_to_ec2_s3" {
  role       = aws_iam_role.ec2_s3_access_role.name
  policy_arn = aws_iam_policy.cloudwatch_agent_policy.arn
}

###############################
# Section 2: IAM Resources for CloudWatch Agent
###############################

# IAM Role for the CloudWatch Agent to publish logs and metrics.
resource "aws_iam_role" "cloudwatch_agent_role" {
  name = "cloudwatch_agent_role"

  # Trust policy that allows EC2 instances to assume this role.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action    = "sts:AssumeRole"
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
        Effect   = "Allow"
        Action   = [
          "cloudwatch:PutMetricData"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
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
