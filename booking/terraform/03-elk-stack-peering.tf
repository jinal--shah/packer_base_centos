# Peering with ELK VPC
# Required to allow access on VPN to Private IP/DNS
# - https://www.terraform.io/docs/providers/aws/r/vpc_peering.html

resource "aws_vpc_peering_connection" "elk" {
  peer_owner_id = "${var.peer_owner_id}"
  peer_vpc_id = "${var.peer_vpc_id_elk}"
  vpc_id = "${aws_vpc.default.id}"
  # Accept the peering (you need to be the owner of both VPCs)
  auto_accept = true

  tags {
    Name        = "${var.tag_project}-peering-to-elk"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Service     = "${var.tag_service}"
    Role        = "${var.tag_role}"
    Creator     = "${var.tag_creator}"
  }
}

resource "aws_route" "elk" {
  route_table_id = "${var.route-table-elk}"
  destination_cidr_block = "${var.vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.elk.id}"
}
