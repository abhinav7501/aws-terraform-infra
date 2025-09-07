
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
    cidr_block = "0.0.0/0"
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
resource "aws_security_group" "sg_alb" {
  name        = "alb-sg"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"   # correction: use "tcp", not "ssh"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_ec2" {
  name        = "sg-ec2"
  description = "Allow inbound traffic only from load balancers"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [ aws_security_group.sg_alb.id ]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "s3" {
    bucket = "unique-sreops-bucket"
  
}

resource "aws_instance" "webserver1" {
  ami               = "ami-0261755bbcb8c4a84"
  instance_type     = "t3.micro"
  subnet_id         = aws_subnet.public_sub1.id
  security_groups   = [aws_security_group.sg_ec2.id]
  user_data         = base64encode(file("user_data.sh"))
}

resource "aws_instance" "webserver2" {
  ami               = "ami-0261755bbcb8c4a84"
  instance_type     = "t3.micro"
  subnet_id         = aws_subnet.public_sub2.id
  security_groups   = [aws_security_group.sg_ec2.id]
  user_data         = base64encode(file("user_data.sh"))
}resource "aws_lb" "alb" {
  name               = "app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_alb.id]
  subnets            = [aws_subnet.public_sub1.id, aws_subnet.public_sub2.id]
}

resource "aws_lb_target_group" "alb_target_group" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/"
    port = "traffic-port"   
  }
}

resource "aws_lb_target_group_attachment" "alb_target_group_attachment1" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "alb_target_group_attachment2" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}

resource "aws_lb_listener" "lb_listener_1" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

output "alb_dns_name" {
    value = aws_lb.alb.dns_name
  
}