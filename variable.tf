variable "profile" {
  type        = string
  description = "Profile of AWS - dev"
}

variable "region" {
  type        = string
  description = "Region to deploy the resources"
}

variable "cidr_block" {
  type        = string
  description = "cidr_block for VPC"
}

variable "vpc_name" {
  type        = string
  description = "Tag name of VPC"
}

variable "public_subnet_count" {
  type        = string
  description = "Number of public subnets"
}

variable "public_cidrs" {
  type        = list(string)
  description = "Value of public cidrs"
}

variable "private_subnet_count" {
  type        = string
  description = "Number of private subnets"
}

variable "private_cidrs" {
  type        = list(string)
  description = "Value of private cidrs"
}

variable "public_route_cidr" {
  type        = string
  description = "Value of private cidrs"
}

data "aws_availability_zones" "available" {
  state = "available"
}

variable "ami_id" {
  type        = string
  description = "Custom AMI ID for EC2 instance"
}


variable "key_name" {
  description = "Name of the SSH key pair for EC2"
  type        = string
}

output "vpc_id" {
  value       = aws_vpc.primary_vpc.id
  description = "The ID of the newly created VPC"
}

variable "app_port" {
  type        = number
  description = "Port on which the application runs"
}

# variable "subnet_id" {
#   description = "Subnet ID where the EC2 instance will be launched"
#   type        = string
# }

# variable "security_group_name" {
#   description = "Security group name for the EC2 instance"
#   type        = string
# }


variable "common_tags" {
  description = "Common Tags"
  default     = {}
  type        = map(string)
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "db_username" {
  type        = string
  description = "Database username for the RDS instance"
}

variable "db_password" {
  type        = string
  description = "Database password for the RDS instance"
  sensitive   = true
}

variable "db_name" {
  type        = string
  description = "Name of the RDS database"
  default     = "app_db"
}

variable "iam_instance_profile_name" {
  description = "IAM Instance Profile name for EC2 instances"
  type        = string
}

# variable "public_subnet_ids" {
#   description = "List of public subnet IDs"
#   type        = list(string)
# }

variable "route53_zone_id" {
  description = "Route 53 Hosted Zone ID for the domain/subdomain"
  type        = string
}

variable "domain_name" {
  description = "The domain or subdomain name (e.g., dev.pragatianrote.me)"
  type        = string
}

variable "cpu_high_threshold" {
  description = "CPU utilization threshold for scaling up (in percent)"
  type        = number
  default     = 8
}

variable "cpu_low_threshold" {
  description = "CPU utilization threshold for scaling down (in percent)"
  type        = number
  default     = 7
}