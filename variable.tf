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