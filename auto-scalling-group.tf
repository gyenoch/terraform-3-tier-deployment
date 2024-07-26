# This is a launch configuration the auto scaling group is going to use to provision new instances
resource "aws_launch_template" "auto-scaling-group" {
  name_prefix   = "auto-scaling-group"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key-pair
  user_data     = filebase64("${path.module}/user_data.sh")
  network_interfaces {
    # subnet_id       = aws_subnet.pub-sn-1.id
    security_groups = [aws_security_group.Webserver_security_group.id]
  }
  tags = {
    Name = "auto-scaling-group"
  }
}

# The autocaling group to increase and decrease instances based on the traffic to the instances
resource "aws_autoscaling_group" "asg-1" {
  vpc_zone_identifier = [aws_ssm_parameter.pri-sn-1.value, aws_ssm_parameter.pri-sn-2.value]
  desired_capacity    = 2
  min_size            = 1
  max_size            = 5

  launch_template {
    id      = aws_launch_template.auto-scaling-group.id
    version = "$Latest"
  }
}

# The policy to attach the autoscaling group to the load balancer in other for the lb to route traffic to the ASG
resource "aws_autoscaling_attachment" "example" {
  autoscaling_group_name = aws_autoscaling_group.asg-1.id
  lb_target_group_arn    = aws_lb_target_group.alb_target_group.arn
}
