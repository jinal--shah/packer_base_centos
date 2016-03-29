# dns
resource "aws_route53_record" "snap" {
   zone_id = "${var.aws_route53_zone}"
   name = "${var.snap_cname}-${var.tag_environment}"
   type = "CNAME"
   ttl = "60"
   records = ["${aws_elb.nginx.dns_name}"]
}
