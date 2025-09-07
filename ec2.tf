resource "aws_instance" "webserver1" {
  ami               = "ami-0261755bbcb8c4a84"
  instance_type     = "t3.micro"
  subnet_id         = aws_subnet.public_sub1.id
  security_groups   = [aws_security_group.sg.id]
  user_data         = base64encode(file("user_data.sh"))
}

resource "aws_instance" "webserver2" {
  ami               = "ami-0261755bbcb8c4a84"
  instance_type     = "t3.micro"
  subnet_id         = aws_subnet.public_sub2.id
  security_groups   = [aws_security_group.sg.id]
  user_data         = base64encode(file("user_data.sh"))
}
