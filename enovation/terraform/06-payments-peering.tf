# Peering with payments VPC
# Required to allow access on VPN to Private IP/DNS
# - https://www.terraform.io/docs/providers/aws/r/vpc_peering.html

variable "peer_vpc_id_payments" {
  description = "Peer Microservice VPC with payments-VPC ID"
}

variable "cidr-payments" {
  description = "CIDR for payments-routetable"
}

variable "route-table-payments" {
  description = "Route Table for payments VPC"
}

variable "domain_name_servers" {
  default = "AmazonProvidedDNS"
}


resource "aws_vpc_peering_connection" "payments" {
  peer_owner_id = "${var.peer_owner_id}"
  peer_vpc_id = "${var.peer_vpc_id_payments}"
  vpc_id = "${aws_vpc.default.id}"
  # Accept the peering (you need to be the owner of both VPCs)
  auto_accept = true

  tags {
    Name        = "${var.tag_project}-peering-to-payments"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Service     = "${var.tag_service}"
    Creator     = "${var.tag_creator}"
    Role        = "Network"
  }
}

resource "aws_route" "payments" {
  route_table_id = "${var.route-table-payments}"
  destination_cidr_block = "${var.vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.payments.id}"
}
