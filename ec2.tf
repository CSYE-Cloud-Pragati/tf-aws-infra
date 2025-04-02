# resource "aws_instance" "webapp_instance" {
#   ami                    = var.ami_id
#   key_name               = var.key_name
#   instance_type          = var.instance_type
#   vpc_security_group_ids = [aws_security_group.application_sg.id]
#   subnet_id              = aws_subnet.public_subnet[0].id

#   root_block_device {
#     volume_size           = 25
#     volume_type           = "gp2"
#     delete_on_termination = true
#   }

#   disable_api_termination = false

#   iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

#   user_data = <<-EOF
#     #!/bin/bash

#     # Set environment variables
#     cat <<EOT > /opt/csye6225/.env
#     DB_HOST=${aws_db_instance.app_db.address}
#     DB_PORT=${aws_db_instance.app_db.port}
#     DB_NAME=${aws_db_instance.app_db.db_name}
#     DB_USERNAME=${var.db_username}
#     DB_PASSWORD=${var.db_password}
#     PORT=8080
#     S3_BUCKET=${aws_s3_bucket.app_bucket.id}
#     NODE_ENV=prod
#     USE_SSL=true
#     EOT

#     # Restart your app
#     systemctl daemon-reload
#     systemctl restart application.service
#   EOF

#   depends_on = [aws_db_instance.app_db]

#   tags = {
#     Name = "WebApp-Instance"
#   }
# }
