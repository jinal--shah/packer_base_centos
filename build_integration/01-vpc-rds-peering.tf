resource "aws_vpc_peering_connection" "db" {
    peer_owner_id = "018274991670"
    peer_vpc_id = "vpc-5b49433e"
    vpc_id = "${aws_vpc.default.id}"
      auto_accept = true
}

resource "aws_route" "peering-route-1a" {
  route_table_id = "rtb-e037ce84"
  destination_cidr_block = "${var.private_subnet_cidr_1a}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.db.id}"
}

resource "aws_route" "peering-route-1b" {
  route_table_id = "rtb-e037ce84"
  destination_cidr_block = "${var.private_subnet_cidr_1b}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.db.id}"
}

resource "aws_route" "db-peering" {
  route_table_id = "${aws_route_table.private.id}"
  destination_cidr_block = "${var.db_vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.db.id}"
}
