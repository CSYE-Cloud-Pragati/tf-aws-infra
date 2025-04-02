resource "aws_security_group" "application_sg" {
  name   = "app-security-group"
  vpc_id = aws_vpc.primary_vpc.id


  ingress {
    description = "Allow SSH access from trusted IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace <YOUR_IP>/32 with your actual IP address
  }

  ingress {
    description     = "Allow web traffic from LB only on app port"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id] # Reference the LB security group
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-security-group"
  }
}

resource "aws_security_group" "db_security_group" {
  name        = "db-security-group"
  description = "Security group for RDS instances"
  vpc_id      = aws_vpc.primary_vpc.id


  ingress {
    description     = "Allow inbound traffic from the application SG"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.application_sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "database-security-group"
  }
}
