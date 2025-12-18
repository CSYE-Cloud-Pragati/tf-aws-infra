# tf-aws-infra — Terraform AWS Infrastructure (CSYE 6225)

This repository contains the **Terraform Infrastructure-as-Code** for deploying the `webapp` service to AWS.

It provisions a production-style setup including:
- VPC + subnets + routing
- Application Load Balancer (ALB)
- Auto Scaling Group (ASG) using a Launch Template
- PostgreSQL database on Amazon RDS (private subnet)
- S3 bucket
- KMS encryption
- IAM roles/policies for EC2
- Route 53 record(s)

This repo is designed to work **together** with the `webapp` repository.

---

## How it fits with the WebApp repo

- **webapp** builds the backend + produces a new AMI using Packer
- **tf-aws-infra** deploys that AMI by wiring it into:
  - Launch Template → Auto Scaling Group → EC2 instances behind an ALB

In short:
**WebApp = application + AMI**
**tf-aws-infra = cloud environment that runs it**

---

## Infrastructure overview (what gets created)

### Networking (VPC baseline)
- VPC
- Public subnets (for ALB / internet-facing components)
- Private subnets (for RDS and internal resources)
- Internet Gateway (IGW)
- Route tables + associations

### Compute & traffic routing
- Application Load Balancer (ALB)
- Security groups for ALB and EC2
- Launch Template (points to the AMI created from webapp repo)
- Auto Scaling Group (ASG) to scale EC2 instances

### Data & storage
- Amazon RDS (PostgreSQL) in private subnets
- S3 bucket for object storage / uploads (as used by the webapp)

### Security & encryption
- AWS KMS key(s) for encryption (S3 / EBS / RDS as configured)
- IAM instance role & policies (least-privilege access for EC2)
- Route 53 record(s) for domain routing
- ACM certificate is assumed/used for HTTPS via ALB (based on configuration)

### Observability
- CloudWatch integration (metrics/logs/alarms as configured)
  
---

## Prerequisites

- AWS CLI configured
- Terraform installed (>= 1.x)
- Permissions to create VPC, ALB, ASG, RDS, IAM, Route53, KMS, S3 resources

---

## Typical workflow

### 1) Build / update AMI (in webapp repo)
- Run packer workflow (or manually build) to generate a new AMI
- Capture the resulting AMI ID

### 2) Deploy infra (in this repo)

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

## Importing an SSL Certificate into AWS Certificate Manager

```
aws acm import-certificate \
  --certificate file://path/to/your_certificate.crt \
  --private-key file://path/to/your_private_key.key \
  --certificate-chain file://path/to/your_certificate_chain.crt \
  --region us-east-1
```
