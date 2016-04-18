# Microservice
output "main_mircoservice_endpoint" {
  value = "https://${aws_route53_record.endpoint.fqdn}"
}
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
output "payments_route_table_id" {
  value = "${aws_route_table.private.id}"
}
output "eip_nat_gateway" {
  value = "${aws_eip.nat.public_ip}"
}
