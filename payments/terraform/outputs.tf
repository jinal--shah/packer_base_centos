# General
output "region" {
  value = "${var.region}"
}
output "vpc_id" {
  value = "${aws_vpc.default.id}"
}
output "vpc_cidr" {
  value = "${var.vpc_cidr}"
}
output "eip_nat_gateway" {
  value = "${aws_eip.nat.public_ip}"
}
# Microservice
output "main_mircoservice_endpoint" {
  value = "${aws_route53_record.endpoint.fqdn}"
}