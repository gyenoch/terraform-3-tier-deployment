# Bastion Host instance for SSH access into the private subnet ec2 instance, which can be used to access the DB
resource "aws_instance" "Public-WebTemplate" {
  ami             = data.aws_ami.ubuntu.id // Ubuntu  AMI
  instance_type   = var.instance_type
  subnet_id       = aws_ssm_parameter.pub-sn-1.value
  security_groups = [aws_security_group.alb_security_group.id]
  key_name        = var.key-pair

  tags = {
    Name = "${var.name}-web-public-1"
  }
}
