#################################################
 # EC2 -ActiveMQ
resource "aws_instance" "amq" {
  ami = "${var.ami_amq}"
  instance_type = "${var.instance_type}"
  key_name = "${var.aws_key_name}"
  subnet_id = "${aws_subnet.eu-west-1a.id}"
  vpc_security_group_ids = ["${aws_security_group.amq.id}"]

  tags {
    Name = "${var.tag_project}-${var.tag_environment}-vpc"
  }
}

resource "aws_route53_record" "mq-dns" {
   zone_id = "${aws_route53_zone.int.id}"
#   name = "mq1-${var.buildnum}"
   name = "mq1"
   type = "A"
   ttl = "60"
   records = ["${aws_instance.amq.private_ip}"]
}

################################################
# AMQ Security group
resource "aws_security_group" "amq" {
  name = "${var.tag_project}-${var.tag_environment}-amq"
  description = "{var.tag_project}-${var.tag_environment}"
  vpc_id = "${aws_vpc.default.id}"

  # SSH access
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  # AMQ access
  ingress {
    from_port = 61616
    to_port = 61616
    protocol = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
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
    Role        = "${var.tag_role}"
    Creator     = "${var.tag_creator}"
  }
}


#################################################
# DHCP Options
resource "aws_vpc_dhcp_options" "default" {
  domain_name = "${aws_route53_zone.int.name}"
  domain_name_servers = ["${var.domain_name_servers}"]

  tags {
    Name        = "${var.tag_project}-${var.tag_environment}-dopt"
    Build       = "Automatic"
    Creator     = "${var.tag_creator}"
    Department  = "${var.tag_department}"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Service     = "${var.tag_service}"
  }
}

resource "aws_vpc_dhcp_options_association" "default" {
  vpc_id = "${aws_vpc.default.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.default.id}"
}

#################################################
# ELB
resource "aws_elb" "backend" {
  name = "${var.tag_project}-${var.tag_environment}-BACK"

  subnets = [
    "${aws_subnet.eu-west-1a.id}",
    "${aws_subnet.eu-west-1b.id}"
  ]
  internal = true
  connection_draining = true
  cross_zone_load_balancing = true
  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 5
    timeout = 5
    target = "HTTP:8080/swagger-ui.html"
    interval = 30
  }
  security_groups = ["${aws_security_group.backend.id}"]
  tags {
    Name        = "${var.tag_project}-${var.tag_environment}-asg-sg"
    Build       = "Automatic"
    Creator     = "${var.tag_creator}"
    Department  = "${var.tag_department}"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Role        = "${var.tag_role}"
    Service     = "${var.tag_service}"
  }
}

resource "aws_route53_record" "elb-int" {
  zone_id = "${aws_route53_zone.int.id}"
  name = "backend-elb"
  type = "A"
  alias = {
    name = "${aws_elb.backend.dns_name}"
    zone_id = "${aws_elb.backend.zone_id}"
    evaluate_target_health = true
  }
  depends_on = ["aws_route53_zone.int"]
}

#################################################
# Create ASG & Launchconfig
#################################################
resource "aws_autoscaling_group" "backend" {
  name = "${var.tag_project}-${var.tag_environment}-backend"
  max_size = "${var.asg_max}"
  min_size = "${var.asg_min}"
  desired_capacity = "${var.asg_desired}"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.backend.name}"
  vpc_zone_identifier = ["${aws_subnet.eu-west-1a.id}","${aws_subnet.eu-west-1b.id}"]
  load_balancers = ["${aws_elb.backend.name}"]
  tag {
    key = "Name"
    value = "${var.tag_project}-${var.tag_environment}-asg"
    propagate_at_launch = "true"
  }
  depends_on = ["aws_instance.amq"]
}

resource "aws_launch_configuration" "backend" {
  name = "${var.tag_project}-${var.tag_environment}-LaunchConfig-888"
  image_id = "${var.ami_appserver}"
  instance_type = "${var.instance_type}"
  associate_public_ip_address = false
  security_groups = ["${aws_security_group.backend.id}"]
  user_data = "${file("./userdata.sh")}"
  key_name = "${var.aws_key_name}"
}

#################################################
# Security Group HTTP, MySQL and SSH access
#################################################
resource "aws_security_group" "backend" {
  name = "${var.tag_project}-${var.tag_environment}"
  description = "{var.tag_project}-${var.tag_environment}"
  vpc_id = "${aws_vpc.default.id}"

  # SSH access
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  # AMQ access
  ingress {
    from_port = 61616
    to_port = 61616
    protocol = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  # MySQL access
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["${var.db_vpc_cidr}"]
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
    Role        = "${var.tag_role}"
    Creator     = "${var.tag_creator}"
  }
}
