variable "notification_vpc_id" {}
variable "notification_vpc_cidr" {}
variable "notification_route_table_id_1a" {}
variable "notification_route_table_id_1b" {}

resource "aws_vpc_peering_connection" "notification" {
  peer_owner_id = "${var.peer_owner_id}"
  peer_vpc_id = "${var.notification_vpc_id}"
  vpc_id = "${aws_vpc.default.id}"
  auto_accept = true
}

# Add current VPC route into Notification Route Tables
resource "aws_route" "peering-route-notification1a-to-vpc" {
  route_table_id = "${var.notification_route_table_id_1a}"
  destination_cidr_block = "${var.vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.notification.id}"
}

resource "aws_route" "peering-route-notifivation1b-to-vpc" {
  route_table_id = "${var.notification_route_table_id_1b}"
  destination_cidr_block = "${var.vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.notification.id}"
}
