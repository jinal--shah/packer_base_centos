#################################################
# Microservice VPC - RDS
#################################################
# Provider
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}
#################################################
# VPC
resource "aws_vpc" "default" {
  cidr_block = "${var.db_vpc_cidr}"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags {
    Name        = "${var.tag_product}-${var.tag_environment}-db-vpc"
    creator     = "${var.tag_creator}"
    environment = "${var.tag_environment}"
    product     = "${var.tag_product}"
    role        = "${var.tag_db_role}"
    service     = "${var.tag_service}"
    serviceCriticality  = "${var.tag_servicecriticality}"
  }
}
#################################################
# IGW
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name        = "${var.tag_product}-${var.tag_environment}-db-igw"
    creator     = "${var.tag_creator}"
    environment = "${var.tag_environment}"
    product     = "${var.tag_product}"
    role        = "${var.tag_db_role}"
    service     = "${var.tag_service}"
    serviceCriticality  = "${var.tag_servicecriticality}"
  }
}

#################################################
# Private Subnets
resource "aws_subnet" "db-private-subnet-1a" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.db_private_subnet_cidr_1a}"
  availability_zone = "eu-west-1a"

  tags {
    Name        = "${var.tag_product}-${var.tag_environment}-db-private-subnet-1a"
    creator     = "${var.tag_creator}"
    environment = "${var.tag_environment}"
    product     = "${var.tag_product}"
    role        = "${var.tag_db_role}"
    service     = "${var.tag_service}"
    serviceCriticality  = "${var.tag_servicecriticality}"
  }
}

resource "aws_subnet" "db-private-subnet-1b" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.db_private_subnet_cidr_1b}"
  availability_zone = "eu-west-1b"

  tags {
    Name        = "${var.tag_product}-${var.tag_environment}-db-private-subnet-1b"
    creator     = "${var.tag_creator}"
    environment = "${var.tag_environment}"
    product     = "${var.tag_product}"
    role        = "${var.tag_db_role}"
    service     = "${var.tag_service}"
    serviceCriticality  = "${var.tag_servicecriticality}"
  }
}

#################################################
# Security Group
resource "aws_security_group" "default" {
  name = "${var.tag_product}-${var.tag_environment}-db-sg"
  description = "${var.tag_product}-${var.tag_environment}-db-security group"
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name        = "${var.tag_product}-${var.tag_environment}-db-sg"
    creator     = "${var.tag_creator}"
    environment = "${var.tag_environment}"
    product     = "${var.tag_product}"
    role        = "${var.tag_db_role}"
    service     = "${var.tag_service}"
    serviceCriticality  = "${var.tag_servicecriticality}"
  }

  depends_on = ["aws_vpc.default"]
}

#################################################
# Subnet Group
resource "aws_db_subnet_group" "default" {
  name = "${var.tag_product}-${var.tag_environment}-db-sng"
  description = "${var.tag_product}-${var.tag_environment} DB subnet group"
  subnet_ids = [
    "${aws_subnet.db-private-subnet-1a.id}",
    "${aws_subnet.db-private-subnet-1b.id}"
  ]

  tags {
    Name        = "${var.tag_product}-${var.tag_environment}-db-sng"
    creator     = "${var.tag_creator}"
    environment = "${var.tag_environment}"
    product     = "${var.tag_product}"
    role        = "${var.tag_db_role}"
    service     = "${var.tag_service}"
    serviceCriticality  = "${var.tag_servicecriticality}"
  }

  depends_on = [
    "aws_subnet.db-private-subnet-1a",
    "aws_subnet.db-private-subnet-1b"
  ]
}


#################################################
# Outputs
output "db_vpc_id" {
  value = "${aws_vpc.default.id}"
}

output "db_security_group_id" {
  value = "${aws_security_group.default.id}"
}

output "db_subnet_group_id" {
  value = "${aws_db_subnet_group.default.id}"
}

output "db_main_rtb_id" {
  value = "${aws_vpc.default.main_route_table_id}"
}
