resource "aws_launch_template" "webapp_lt" {
  name_prefix   = "webapp_lt_"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.application_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(<<EOF
#!/bin/bash

# Update the system and install necessary tools
sudo apt-get update -y
sudo snap install aws-cli --classic
sudo apt-get install -y jq

# Retrieve the DB password from Secrets Manager and extract plain text using jq
DB_PASSWORD=$(aws secretsmanager get-secret-value --secret-id "db_password_secret" --query 'SecretString' --output text --region ${var.region} | jq -r '.password')

# Create the environment file with the retrieved DB password
cat <<EOT > /opt/csye6225/.env
DB_HOST=${aws_db_instance.app_db.address}
DB_PORT=${aws_db_instance.app_db.port}
DB_NAME=${aws_db_instance.app_db.db_name}
DB_USERNAME=${var.db_username}
PORT=8080
S3_BUCKET=${aws_s3_bucket.app_bucket.id}
NODE_ENV=prod
USE_SSL=true
EOT

echo "DB_PASSWORD=$DB_PASSWORD" >> /opt/csye6225/.env

systemctl daemon-reload
systemctl restart application.service
EOF
  )

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = 25
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "WebApp-Instance"
    }
  }
}
