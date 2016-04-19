# ELB
variable "certificate" {
  description = "Existing Certificate Name to use from AWS"
  default = "STAR.trainz.io"
# default = "wildcard.eurostar.com"
}

resource "aws_elb" "nginx" {
  name = "${var.tag_project}-${var.tag_environment}-MAIN"
#  subnets = ["${aws_subnet.eu-west-1a.id}","${aws_subnet.eu-west-1b.id}"]
  subnets = ["${aws_subnet.eu-west-1a-public.id}","${aws_subnet.eu-west-1b-public.id}"]
  security_groups = ["${aws_security_group.elb.id}"]
  internal = false

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "arn:aws:iam::${var.peer_owner_id}:server-certificate/${var.certificate}"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "TCP:80"
    interval = 30
  }

  tags {
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Service     = "${var.tag_service}"
    Role        = "elb for nginx"
    Creator     = "${var.tag_creator}"
    Department  = "${var.tag_department}"
  }

}


resource "aws_security_group" "elb" {
  name = "${var.tag_project}-${var.tag_environment}-elb"
  description = "Security Group for Nginx ELB"
  vpc_id = "${aws_vpc.default.id}"

  # HTTP access
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  tags {
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Service     = "${var.tag_service}"
    Role        = "nginx-elb-securitygroup"
    Creator     = "${var.tag_creator}"
    Department  = "${var.tag_department}"
  }
}

