resource "aws_lb" "alb" {
  name               = "app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = [aws_subnet.public_sub1.id, aws_subnet.public_sub2.id]
}

resource "aws_lb_target_group" "alb-target-group" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/"
    port = "traffic-port"   
  }
}

resource "aws_lb_target_group_attachment" "alb-target-group-attachment1" {
  target_group_arn = aws_lb_target_group.alb-target-group.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "alb-target-group-attachment2" {
  target_group_arn = aws_lb_target_group.alb-target-group.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}

resource "aws_lb_listener" "lb-listener-1" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-target-group.arn
  }
}
