variable "servers" {
  default = "1"
}

provider "aws" {
  profile = "default"
  region = "eu-west-2"
}

resource "aws_key_pair" "main" {
    key_name   = "testing-mhristof"
    public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "foobar" {
  name          = "test"
  image_id      = "ami-818597e5"
  instance_type = "t2.micro"
  security_groups = [
      "${aws_security_group.allow_all.id}"
      ]
  key_name = "${aws_key_pair.main.id}"
}

resource "aws_autoscaling_group" "bar" {
  availability_zones        = ["eu-west-2a", "eu-west-2b"]
  name                      = "foobar3-terraform-test"
  max_size                  = 2
  min_size                  = "${var.servers}"
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = "${var.servers}"
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.foobar.name}"

  tag {
    key                 = "foo"
    value               = "bar"
    propagate_at_launch = true
  }

  tag {
    key                 = "lorem"
    value               = "ipsum"
    propagate_at_launch = false
  }
}

resource "aws_autoscaling_policy" "bat" {
  name                   = "foobar3-terraform-test"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.bar.name}"
}

resource "aws_cloudwatch_metric_alarm" "bat" {
  alarm_name          = "terraform-test-foobar5"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.bar.name}"
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.bat.arn}"]
}
