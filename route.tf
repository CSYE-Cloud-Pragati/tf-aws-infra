resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.primary_vpc.id

  tags = {
    Name = "${var.vpc_name}_private_route_table"
  }
}

resource "aws_route_table_association" "private_route_table_association" {
  count          = 3
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.primary_vpc.id

  tags = {
    Name = "${var.vpc_name}_public_route_table"
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  count          = 3
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = var.public_route_cidr
  gateway_id             = aws_internet_gateway.internet_gateway.id
}