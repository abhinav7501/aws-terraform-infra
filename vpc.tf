resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = {
    Name = "main_vpc"
  }
}

resource "aws_subnet" "public_sub1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "15.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

# resource "aws_subnet" "private_sub1" {
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = "15.0.3.0/24"
#   availability_zone       = "us-east-1a"
#   map_public_ip_on_launch = false
# }

resource "aws_subnet" "public_sub2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "15.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

# resource "aws_subnet" "private_sub2" {
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = "15.0.4.0/24"
#   availability_zone       = "us-east-1b"
#   map_public_ip_on_launch = false
# }

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_rt_assoc1" {
  subnet_id      = aws_subnet.public_sub1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_assoc2" {
  subnet_id      = aws_subnet.public_sub2.id
  route_table_id = aws_route_table.public_rt.id
}
