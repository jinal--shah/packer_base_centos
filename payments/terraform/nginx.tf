variable "ami_nginx" {}

variable "instance_type_nginx" {
  default = "t2.micro"
  description = "AWS instance type"
}

variable "asg_min_nginx" {
  description = "Min numbers of servers in ASG"
  default = "2"
}

variable "asg_max_nginx" {
  description = "Max numbers of servers in ASG"
  default = "3"
}

variable "asg_desired_nginx" {
  description = "Desired numbers of servers in ASG"
  default = "2"
}

#################################################
# Create ASG & Launchconfig
#################################################
resource "aws_autoscaling_notification" "nginx" {
  group_names = [
    "${aws_autoscaling_group.nginx.name}"
  ]
  notifications  = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
  ]
  topic_arn = "${aws_sns_topic.payments.arn}"
}

resource "aws_autoscaling_group" "nginx" {
  name = "${var.tag_project}-${var.tag_environment}-nginx"
  max_size = "${var.asg_max_nginx}"
  min_size = "${var.asg_min_nginx}"
  desired_capacity = "${var.asg_desired_nginx}"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.nginx.name}"
  lifecycle { create_before_destroy = true }
  vpc_zone_identifier = ["${aws_subnet.eu-west-1a.id}","${aws_subnet.eu-west-1b.id}"]
  load_balancers = ["${aws_elb.nginx.name}"]
  ## Nginx requires resolvable dns entries to start service
  depends_on = ["aws_route53_record.elb-backend","aws_elb.backend"]
  tag {
    key = "Name"
    value = "${var.tag_project}-${var.tag_environment}-nginx"
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
}

resource "aws_launch_configuration" "nginx" {
  name_prefix = "${var.tag_project}-${var.tag_environment}-LC-nginx-"
  image_id = "${var.ami_nginx}"
  instance_type = "${var.instance_type_nginx}"
  lifecycle { create_before_destroy = true }
#  associate_public_ip_address = true
  security_groups = ["${aws_security_group.nginx.id}"]
#  user_data = "${file("./userdata.sh")}"
  key_name = "${var.aws_key_name}"
  ## Nginx requires resolvable dns entries to start service
#  depends_on = ["aws_route53_record.elb-backend","aws_route53_record.elb-frontend"]
}

#################################################
# Security Group HTTP, MySQL and SSH access
#################################################
resource "aws_security_group" "nginx" {
  name = "${var.tag_project}-${var.tag_environment}-nginx"
  description = "${var.tag_project}-${var.tag_environment}-sg"
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
    from_port = 8080
    to_port = 8080
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
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Service     = "${var.tag_service}"
    Creator     = "${var.tag_creator}"
    Role        = "securitygroup"
    Department  = "${var.tag_department}"
  }
}
