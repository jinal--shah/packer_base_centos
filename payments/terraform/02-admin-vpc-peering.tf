#################################################
# Peering with Admin VPC
# Required to allow access on VPN to Private IP/DNS
#################################################

resource "aws_vpc_peering_connection" "admin" {
  peer_owner_id = "${var.peer_owner_id}"
  peer_vpc_id = "${var.peer_vpc_id}"
  vpc_id = "${aws_vpc.default.id}"
  # Accept the peering (you need to be the owner of both VPCs)
  auto_accept = true

  tags {
    Name        = "${var.tag_project}-peering-toadmin"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Service     = "${var.tag_service}"
    Role        = "${var.tag_role}"
    Creator     = "${var.tag_creator}"
  }
}

resource "aws_route" "admin-vpn" {
  route_table_id = "${var.route-table-adminvpn}"
  destination_cidr_block = "${var.vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.admin.id}"
}

resource "aws_route" "admin-vpn-unknown1" {
  route_table_id = "${var.route-table-adminvpn-unknown1}"
  destination_cidr_block = "${var.vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.admin.id}"
}

resource "aws_route" "admin-vpn-unknown2" {
  route_table_id = "${var.route-table-adminvpn-unknown2}"
  destination_cidr_block = "${var.vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.admin.id}"
}

resource "aws_route" "admin-vpn-unknown3" {
  route_table_id = "${var.route-table-adminvpn-unknown3}"
  destination_cidr_block = "${var.vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.admin.id}"
}
