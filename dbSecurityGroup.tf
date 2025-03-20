# resource "aws_security_group" "db_sg" {
#   name        = "database-sg"
#   description = "Security group for RDS database"
#   vpc_id      = aws_vpc.primary_vpc.id

#   # Allow database traffic from application security group
#   ingress {
#     from_port       = 5432 # PostgreSQL port (use 3306 for MySQL/MariaDB)
#     to_port         = 5432
#     protocol        = "tcp"
#     security_groups = [aws_security_group.application_sg.id] # Changed from app_sg to app_security_group
#   }

#   # No direct outbound access needed for database
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = var.common_tags
# }