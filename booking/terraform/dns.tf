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

# dns
resource "aws_route53_record" "endpoint" {
   zone_id = "${var.aws_route53_zone}"
   name = "${var.endpoint_cname}-${var.tag_environment}"
   type = "CNAME"
   ttl = "60"
   records = ["${aws_elb.nginx.dns_name}"]
}

#resource "aws_route53_record" "database" {
#   zone_id = "${aws_route53_zone.int.id}"
#   name = "database"
#   type = "CNAME"
#   ttl = "60"
#   records = ["${var.db-endpoint}"]
#}
