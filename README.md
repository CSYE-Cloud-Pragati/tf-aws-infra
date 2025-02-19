# tf-aws-infra (CSYE 6225)

This repository contains Terraform configurations to set up a complete AWS networking infrastructure including VPC, Subnets, Internet Gateway, and Route Tables.

## Infrastructure Overview

The infrastructure includes:
- 1 VPC
- 3 Public Subnets
- 3 Private Subnets
- 1 Internet Gateway
- Public and Private Route Tables
- Appropriate Routes and Associations

## Prerequisites

1. AWS CLI installed and configured with appropriate credentials

   ```bash
   aws configure --profile dev
   ```

2. Terraform installed (version >= 1.0.0)

   ```bash
   # For Linux
   sudo apt-get update && sudo apt-get install -y terraform

   # For Mac
   brew install terraform
   ```

## Usage

1. Clone the repository

   ```bash
   git clone <repository-url>
   cd tf-aws-infra
   ```

2. Initialize Terraform

   ```bash
   terraform init
   ```

3. Review the plan

   ```bash
   terraform plan -var-file="your_tfvars_file"
   ```

4. Apply the configuration

   ```bash
   terraform apply
   ```

5. To destroy the infrastructure
   ```bash
   terraform destroy
   ```
