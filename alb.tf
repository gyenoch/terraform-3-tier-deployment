resource "aws_lb" "application-load-balancer" {
  name                       = "web-external-load-balancer"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_security_group.id]
  subnets                    = [aws_ssm_parameter.pub-sn-1.value, aws_ssm_parameter.pub-sn-2.value]
  enable_deletion_protection = false

  tags = {
    Name = "${var.name}-var.lb"
  }
}

resource "aws_lb_target_group" "alb_target_group" {
  name     = "app-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc-01.id
}


# create a listeneer on port 80 with redirect action

resource "aws_lb_listener" "alb-http-listener" {
  load_balancer_arn = aws_lb.application-load-balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}
