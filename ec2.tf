resource "aws_instance" "webserver1" {
  ami             = "ami-0360c520857e3138f"
  instance_type   = "t3.micro"
  subnet_id       = aws_subnet.public_sub1.id
  security_groups = [aws_security_group.sg_ec2.id]
  user_data       = base64encode(file("userdata.sh"))
  key_name        = "aws-login"
}

resource "aws_instance" "webserver2" {
  ami             = "ami-0360c520857e3138f"
  instance_type   = "t3.micro"
  subnet_id       = aws_subnet.public_sub1.id
  security_groups = [aws_security_group.sg_ec2.id]
  user_data       = base64encode(file("userdata1.sh"))
  key_name        = "aws-login"
}
