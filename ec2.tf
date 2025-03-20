resource "aws_instance" "webapp_instance" {
  ami                    = var.ami_id
  key_name               = var.key_name
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.application_sg.id]
  subnet_id              = aws_subnet.public_subnet[0].id


  root_block_device {
    volume_size           = 25
    volume_type           = "gp2"
    delete_on_termination = true
  }

  # Disable accidental termination protection
  disable_api_termination = false


  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # User data script to configure MySQL database connection
  user_data = <<-EOF
    #!/bin/bash
    
    # Set environment variables for database configuration
    
    rm -f /opt/csye6225/.env
    echo "DB_HOST=${aws_db_instance.app_db.address}" >> /opt/csye6225/.env
    echo "DB_PORT=${aws_db_instance.app_db.port}" >> /opt/csye6225/.env
    echo "DB_NAME=${aws_db_instance.app_db.db_name}" >> /opt/csye6225/.env
    echo "DB_USERNAME=${var.db_username}" >> /opt/csye6225/.env
    echo "DB_PASSWORD=${var.db_password}" >> /opt/csye6225/.env
    echo "PORT=8080" >> /opt/csye6225/.env
    echo "S3_BUCKET=${aws_s3_bucket.app_bucket.id}" >> /opt/csye6225/.env
    
    # Restart webapp service to apply changes
    systemctl restart application.service
  EOF

  # Make sure RDS instance is created before EC2 instance
  depends_on = [aws_db_instance.app_db]

  tags = {
    Name = "WebApp-Instance"
  }
}


variable "ami" {
  description = "machine image number"
  type        = string
}

variable "instance_type" {
  description = "type of instance in ec2"
  type        = string
}


# Add these missing variables
variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
}
