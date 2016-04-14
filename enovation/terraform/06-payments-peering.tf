variable "payments_vpc_id" {}
variable "payments_vpc_cidr" {}
variable "payments_route_table_id" {}

resource "aws_vpc_peering_connection" "payments" {
  peer_owner_id = "${var.peer_owner_id}"
  peer_vpc_id = "${var.payments_vpc_id}"
  vpc_id = "${aws_vpc.default.id}"
  auto_accept = true
}

# Add current VPC route into Notification Route Tables
resource "aws_route" "peering-route-payments-to-vpc" {
  route_table_id = "${var.payments_route_table_id}"
  destination_cidr_block = "${var.vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.payments.id}"
}
