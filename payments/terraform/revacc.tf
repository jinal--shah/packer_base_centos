variable "ami_revacc" {}

variable "instance_type_revacc" {
  default = "t2.medium"
  description = "AWS instance type"
}

variable "asg_min_revacc" {
  description = "Min numbers of servers in ASG"
  default = "1"
}

variable "asg_max_revacc" {
  description = "Max numbers of servers in ASG"
  default = "2"
}

variable "asg_desired_revacc" {
  description = "Desired numbers of servers in ASG"
  default = "1"
}



#################################################
# ELB
resource "aws_elb" "revacc" {
  name = "${var.tag_project}-${var.tag_environment}-revacc"

  subnets = [
    "${aws_subnet.eu-west-1a.id}",
    "${aws_subnet.eu-west-1b.id}"
  ]
  internal = true
  connection_draining = true
  cross_zone_load_balancing = true
  listener {
    instance_port = 9080
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 5
    timeout = 5
    target = "TCP:9080"
    interval = 30
  }
  security_groups = ["${aws_security_group.revacc.id}"]
  tags {
    Name        = "${var.tag_project}-${var.tag_environment}-elb-revacc"
    Build       = "Automatic"
    Creator     = "${var.tag_creator}"
    Department  = "${var.tag_department}"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Service     = "${var.tag_service}"
    Role        = "elb"
  }
}

resource "aws_route53_record" "elb-revacc" {
  zone_id = "${aws_route53_zone.int.id}"
  name = "revacc-elb"
  type = "A"
  alias = {
    name = "${aws_elb.revacc.dns_name}"
    zone_id = "${aws_elb.revacc.zone_id}"
    evaluate_target_health = true
  }
  depends_on = ["aws_route53_zone.int"]
}

#################################################
# Create ASG & Launchconfig
#################################################
resource "aws_autoscaling_policy" "revacc" {
  name = "${var.tag_project}-${var.tag_environment}-revacc"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.revacc.name}"
}

resource "aws_cloudwatch_metric_alarm" "revacc-cpu" {
  alarm_name = "${var.tag_project}-${var.tag_environment}-revacc-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "3"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "80"
  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.revacc.name}"
  }
  alarm_description = "This metric monitor ec2 cpu utilization"
  alarm_actions = ["${aws_autoscaling_policy.revacc.arn}"]
}

resource "aws_autoscaling_notification" "revacc" {
  group_names = [
    "${aws_autoscaling_group.revacc.name}"
  ]
  notifications  = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
  ]
  topic_arn = "${aws_sns_topic.payments.arn}"
}

resource "aws_autoscaling_group" "revacc" {
  name = "${var.tag_project}-${var.tag_environment}-revacc"
  max_size = "${var.asg_max_revacc}"
  min_size = "${var.asg_min_revacc}"
  desired_capacity = "${var.asg_desired_revacc}"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.revacc.name}"
  lifecycle { create_before_destroy = true }
  vpc_zone_identifier = ["${aws_subnet.eu-west-1a.id}","${aws_subnet.eu-west-1b.id}"]
  load_balancers = ["${aws_elb.revacc.name}"]
  tag {
    key = "Name"
    value = "${var.tag_project}-${var.tag_environment}-asg-revacc"
    propagate_at_launch = "true"
  }
  tag {
    key = "Environment"
    value = "${var.tag_environment}"
    propagate_at_launch = "true"
  }
  tag {
    key = "Project"
    value = "${var.tag_project}"
    propagate_at_launch = "true"
  }
  tag {
    key = "Service"
    value = "${var.tag_service}"
    propagate_at_launch = "true"
  }
  tag {
    key = "Creator"
    value = "${var.tag_creator}"
    propagate_at_launch = "true"
  }
  tag {
    key = "Department"
    value = "${var.tag_department}"
    propagate_at_launch = "true"
  }
#  depends_on = ["aws_instance.amq"]
}

resource "aws_launch_configuration" "revacc" {
  name = "${var.tag_project}-${var.tag_environment}-LaunchConfig-revacc"
  image_id = "${var.ami_revacc}"
  instance_type = "${var.instance_type}"
  lifecycle { create_before_destroy = true }
  associate_public_ip_address = false
  security_groups = ["${aws_security_group.revacc.id}"]
#  user_data = "${file("./userdata.sh")}"
  key_name = "${var.aws_key_name}"
}

#################################################
# Security Group HTTP, MySQL and SSH access
#################################################
resource "aws_security_group" "revacc" {
  name = "${var.tag_project}-${var.tag_environment}-revacc"
  description = "${var.tag_project}-${var.tag_environment}"
  vpc_id = "${aws_vpc.default.id}"

  # SSH access
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  # HTTP access
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  # HTTP access
  ingress {
    from_port = 9080
    to_port = 9080
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  # ICMP
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  # outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Creator     = "${var.tag_creator}"
    Department  = "${var.tag_department}"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Service     = "${var.tag_service}"
    Role        = "security"
  }
}
