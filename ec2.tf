###############################################################
# ec2.tf
# This file defines the EC2 instance that runs your web application.
# It uses the instance profile defined in IAM for permissions.
# Do not remove any existing declarations to avoid errors.
###############################################################

resource "aws_instance" "webapp_instance" {
  # AMI ID to launch; this is provided as a variable.
  ami = var.ami_id

  # SSH key name for accessing the instance.
  key_name = var.key_name

  # Instance type (e.g., t2.micro).
  instance_type = var.instance_type

  # Security groups for the instance.
  vpc_security_group_ids = [aws_security_group.application_sg.id]

  # Subnet in which to launch the instance.
  subnet_id = aws_subnet.public_subnet[0].id

  # Root block device configuration.
  root_block_device {
    volume_size           = 25
    volume_type           = "gp2"
    delete_on_termination = true
  }

  # Disable accidental termination protection.
  disable_api_termination = false

  # Attach the IAM instance profile.
  # NOTE: Currently referencing the S3 role that also has CloudWatch permissions attached.
  # If you prefer the dedicated CloudWatch Agent profile, comment this line and
  # uncomment the second line.
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  # iam_instance_profile = aws_iam_instance_profile.cloudwatch_agent_instance_profile.name

  # User data script to configure the environment, embed CloudWatch Agent JSON,
  # create the necessary directory, and restart both the agent and the application.
  user_data = <<-EOF
    #!/bin/bash

    # Remove any existing environment configuration file.
    rm -f /opt/csye6225/.env

    # Set environment variables for database configuration.
    echo "DB_HOST=${aws_db_instance.app_db.address}" >> /opt/csye6225/.env
    echo "DB_PORT=${aws_db_instance.app_db.port}" >> /opt/csye6225/.env
    echo "DB_NAME=${aws_db_instance.app_db.db_name}" >> /opt/csye6225/.env
    echo "DB_USERNAME=${var.db_username}" >> /opt/csye6225/.env
    echo "DB_PASSWORD=${var.db_password}" >> /opt/csye6225/.env
    echo "PORT=8080" >> /opt/csye6225/.env
    echo "S3_BUCKET=${aws_s3_bucket.app_bucket.id}" >> /opt/csye6225/.env
    echo "NODE_ENV=prod" >> /opt/csye6225/.env
    echo "USE_SSL=true" >> /opt/csye6225/.env

    # (Optional) Install or update the CloudWatch Agent if not already on the AMI.
    # This snippet uses apt-get (Ubuntu/Debian). Adjust if your base AMI differs.
    apt-get update -y
    apt-get install -y wget
    wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb -O /tmp/amazon-cloudwatch-agent.deb
    dpkg -i /tmp/amazon-cloudwatch-agent.deb

    # Create the CloudWatch Agent config inline:
    cat <<'CWAGENT_JSON' > /tmp/amazon-cloudwatch-agent.json
    {
      "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "root"
      },
      "metrics": {
        "metrics_collected": {
          "cpu": {
            "measurement": [
              "usage_idle",
              "usage_user",
              "usage_system"
            ],
            "totalcpu": true
          },
          "statsd": {
            "service_address": ":8125",
            "metrics_aggregation_interval": 60
          }
        }
      },
      "logs": {
        "logs_collected": {
          "files": {
            "collect_list": [
              {
                "file_path": "/opt/csye6225/logs/myapp.log",
                "log_group_name": "/aws/amazon-cloudwatch-agent/myapp",
                "log_stream_name": "{instance_id}"
              }
            ]
          }
        }
      }
    }
    CWAGENT_JSON

    # Create the target directory for the CloudWatch Agent config.
    mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/
    # Copy the config to the agent directory.
    cp /tmp/amazon-cloudwatch-agent.json /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
    # Enable and restart the CloudWatch Agent.
    systemctl enable amazon-cloudwatch-agent
    systemctl restart amazon-cloudwatch-agent

    # Restart the application service to apply changes.
    systemctl daemon-reload
    systemctl restart application.service
  EOF

  # Ensure the RDS instance is created before launching this instance.
  depends_on = [aws_db_instance.app_db]

  # Tag the instance for identification.
  tags = {
    Name = "WebApp-Instance"
  }
}
