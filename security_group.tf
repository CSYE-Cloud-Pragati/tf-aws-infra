resource "aws_security_group" "application_sg" {
  name   = "app-security-group"
  vpc_id = aws_vpc.primary_vpc.id 

  # Ingress rules for allowing incoming traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH access from anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP access from anywhere
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTPS access from anywhere
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow app access from anywhere
  }

  # Egress rule: Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Database Security Group for RDS
resource "aws_security_group" "db_security_group" {
  name        = "db-security-group"
  description = "Security group for RDS instances"
  vpc_id      = aws_vpc.primary_vpc.id

  # Allow inbound traffic from the application security group
  ingress {
    from_port       = 5432 
    to_port         = 5432 
    protocol        = "tcp"
    security_groups = [aws_security_group.application_sg.id]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "database-security-group"
  }
}