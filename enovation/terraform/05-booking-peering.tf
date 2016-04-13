# Peering with booking VPC
# Required to allow access on VPN to Private IP/DNS
# - https://www.terraform.io/docs/providers/aws/r/vpc_peering.html

variable "peer_vpc_id_booking" {
  description = "Peer Microservice VPC with booking-VPC ID"
}

variable "cidr-booking" {
  description = "CIDR for booking-routetable"
}

variable "route-table-booking" {
  description = "Route Table for booking VPC"
}

variable "domain_name_servers" {
  default = "AmazonProvidedDNS"
}


resource "aws_vpc_peering_connection" "booking" {
  peer_owner_id = "${var.peer_owner_id}"
  peer_vpc_id = "${var.peer_vpc_id_booking}"
  vpc_id = "${aws_vpc.default.id}"
  # Accept the peering (you need to be the owner of both VPCs)
  auto_accept = true

  tags {
    Name        = "${var.tag_project}-peering-to-booking"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Service     = "${var.tag_service}"
    Creator     = "${var.tag_creator}"
    Role        = "Network"
  }
}

resource "aws_route" "booking" {
  route_table_id = "${var.route-table-booking}"
  destination_cidr_block = "${var.vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.booking.id}"
}
