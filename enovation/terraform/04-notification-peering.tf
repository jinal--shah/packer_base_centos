# Peering with Notification VPC
# Required to allow access on VPN to Private IP/DNS
# - https://www.terraform.io/docs/providers/aws/r/vpc_peering.html

variable "peer_vpc_id_notification" {
  description = "Peer Microservice VPC with notification-VPC ID"
}

variable "cidr-notification" {
  description = "CIDR for notification-routetable"
}

variable "route-table-notification" {
  description = "Route Table for notification VPC"
}

variable "domain_name_servers" {
  default = "AmazonProvidedDNS"
}


resource "aws_vpc_peering_connection" "notification" {
  peer_owner_id = "${var.peer_owner_id}"
  peer_vpc_id = "${var.peer_vpc_id_notification}"
  vpc_id = "${aws_vpc.default.id}"
  # Accept the peering (you need to be the owner of both VPCs)
  auto_accept = true

  tags {
    Name        = "${var.tag_project}-peering-to-notification"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Service     = "${var.tag_service}"
    Creator     = "${var.tag_creator}"
    Role        = "Network"
  }
}

resource "aws_route" "notification" {
  route_table_id = "${var.route-table-notification}"
  destination_cidr_block = "${var.vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.notification.id}"
}
