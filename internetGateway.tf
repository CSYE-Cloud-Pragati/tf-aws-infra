resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.primary_vpc.id


  tags = {
    Name = "${var.vpc_name}_internet_gateway"
  }
}

 