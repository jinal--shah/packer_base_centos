#################################################
 # EC2 -ActiveMQ
resource "aws_instance" "amq" {
  ami = "${var.ami_amq}"
  instance_type = "${var.instance_type}"
  key_name = "${var.aws_key_name}"
  subnet_id = "${aws_subnet.eu-west-1a.id}"
  vpc_security_group_ids = ["${aws_security_group.amq.id}"]

  tags {
    Name        = "${var.tag_project}-${var.tag_environment}-amq"
    Creator     = "${var.tag_creator}"
    Department  = "${var.tag_department}"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Service     = "${var.tag_service}"
    Role        = "amq"
  }
}

resource "aws_route53_record" "amq" {
   zone_id = "${aws_route53_zone.int.id}"
   name = "mq1"
   type = "A"
   ttl = "60"
   records = ["${aws_instance.amq.private_ip}"]
}

################################################
# AMQ Security group
resource "aws_security_group" "amq" {
  name = "${var.tag_project}-${var.tag_environment}-amq"
  description = "${var.tag_project}-${var.tag_environment}"
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
    Creator     = "${var.tag_creator}"
    Department  = "${var.tag_department}"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Service     = "${var.tag_service}"
    Role        = "security"
  }
}
