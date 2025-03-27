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

  disable_api_termination = false

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
    #!/bin/bash

    INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)

    # Set environment variables
    cat <<EOT > /opt/csye6225/.env
    DB_HOST=${aws_db_instance.app_db.address}
    DB_PORT=${aws_db_instance.app_db.port}
    DB_NAME=${aws_db_instance.app_db.db_name}
    DB_USERNAME=${var.db_username}
    DB_PASSWORD=${var.db_password}
    PORT=8080
    S3_BUCKET=${aws_s3_bucket.app_bucket.id}
    NODE_ENV=prod
    USE_SSL=true
    EOT

    # Install CloudWatch Agent
    apt-get update -y
    apt-get install -y wget
    wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb -O /tmp/amazon-cloudwatch-agent.deb
    dpkg -i /tmp/amazon-cloudwatch-agent.deb

    # Create the directory for config if not exists
    mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/

    # Create CloudWatch Agent config (fixed valid schema)
    cat <<CWAGENT_JSON > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
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
            "totalcpu": true,
            "metrics_collection_interval": 60
          },
          "mem": {
            "measurement": [
              "mem_used_percent"
            ],
            "metrics_collection_interval": 60
          },
          "disk": {
            "measurement": [
              "used_percent"
            ],
            "resources": [
              "/"
            ],
            "metrics_collection_interval": 60
          },
          "net": {
            "measurement": [
              "bytes_sent",
              "bytes_recv"
            ],
            "metrics_collection_interval": 60
          },
          "statsd": {
            "service_address": ":8125"
          }
        }
      },
      "logs": {
        "logs_collected": {
          "files": {
            "collect_list": [
              {
                "file_path": "/opt/csye6225/logs/webapp.log",
                "log_group_name": "/aws/amazon-cloudwatch-agent/webapp",
                "log_stream_name": "{instance_id}",
                "retention_in_days": 7
              }
            ]
          }
        }
      }
    }
    CWAGENT_JSON

    # Set ownership and permissions
    mkdir -p /opt/csye6225/logs
    chown -R csye6225:csye6225 /opt/csye6225
    chmod -R 755 /opt/csye6225

    chown root:root /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
    chmod 644 /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

    # Restart CloudWatch Agent
    systemctl enable amazon-cloudwatch-agent
    systemctl restart amazon-cloudwatch-agent

    # Restart your app
    systemctl daemon-reload
    systemctl restart application.service
  EOF

  depends_on = [aws_db_instance.app_db]

  tags = {
    Name = "WebApp-Instance"
  }
}
