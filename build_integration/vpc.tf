#################################################
# Microservice VPC
#################################################
# Provider
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}
#################################################
# VPC
#################################################
resource "aws_route53_zone" "main" {
  name = "eno.trainz.io"
}

resource "aws_route53_zone" "int" {
  name = "v1-1-eno.trainz.io"
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Environment = "int"
  }
}

resource "aws_vpc" "default" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags {
    Name        = "test-${var.tag_service}-${tag_environment}-vpc"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Service     = "${var.tag_service}"
    Role        = "${var.tag_role}"
    Creator     = "${var.tag_creator}"
    Department  = "${var.tag_department}"
    Creator     = "${var.tag_creator}"
  }
}
#################################################
# IGW
#################################################
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name        = "${var.tag_project}-igw"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Service     = "${var.tag_service}"
    Role        = "${var.tag_role}"
    Creator     = "${var.tag_creator}"
  }
}

#################################################
# NAT Gateway
#################################################
resource "aws_nat_gateway" "gw" {
    allocation_id = "${aws_eip.nat.id}"
    subnet_id = "${aws_subnet.eu-west-1a-public.id}"
    depends_on = ["aws_internet_gateway.default"]
}

resource "aws_eip" "nat" {
    vpc = true
#    public_ip = "${var.aws_eip_nat}"
}
#################################################
# Public Subnets
#################################################
resource "aws_subnet" "eu-west-1a-public" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.public_subnet_cidr_1a}"
  availability_zone = "eu-west-1a"

  tags {
    Name        = "${var.tag_project}-${var.tag_environment}-public-subnet-1a"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Service     = "${var.tag_service}"
    Role        = "${var.tag_role}"
    Creator     = "${var.tag_creator}"
  }
}
resource "aws_subnet" "eu-west-1b-public" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.public_subnet_cidr_1b}"
  availability_zone = "eu-west-1b"

  tags {
    Name       = "${var.tag_project}-${var.tag_environment}-public-subnet-1a"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Service     = "${var.tag_service}"
    Role        = "${var.tag_role}"
    Creator     = "${var.tag_creator}"
  }
}
#################################################
# Private Subnets
#################################################
resource "aws_subnet" "eu-west-1a" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block = "${var.private_subnet_cidr_1a}"
  availability_zone = "eu-west-1a"

  tags {
    Name        = "${var.tag_project}-${var.tag_environment}-private-subnet-1a"    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Service     = "${var.tag_service}"
    Role        = "${var.tag_role}"
    Creator     = "${var.tag_creator}"
    Department  = "${var.tag_department}"
    Environment = "${var.tag_environment}"
  }
}

resource "aws_subnet" "eu-west-1b" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block = "${var.private_subnet_cidr_1b}"
  availability_zone = "eu-west-1b"

  tags {
    Name        = "${var.tag_project}-PrivateSubnet-1b"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Service     = "${var.tag_service}"
    Role        = "${var.tag_role}"
    Creator     = "${var.tag_creator}"
  }
}
#################################################
# Route Table
#################################################
resource "aws_route_table" "private" {
    vpc_id = "${aws_vpc.default.id}"
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.gw.id}"
    }
    route {
        cidr_block = "${var.cidr-admin}"
        nat_gateway_id = "${aws_vpc_peering_connection.admin.id}"
    }
    route {
        cidr_block = "${var.cidr-elk}"
        nat_gateway_id = "${aws_vpc_peering_connection.elk.id}"
    }


  tags {
    Name        = "${var.tag_project}-rtb-private"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Service     = "${var.tag_service}"
    Role        = "${var.tag_role}"
    Creator     = "${var.tag_creator}"
  }
}

resource "aws_route_table_association" "eu-west-1a-rta" {
    subnet_id = "${aws_subnet.eu-west-1a.id}"
    route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "eu-west-1b-rta" {
    subnet_id = "${aws_subnet.eu-west-1b.id}"
    route_table_id = "${aws_route_table.private.id}"
}


resource "aws_route_table" "public" {
    vpc_id = "${aws_vpc.default.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }
    route {
        cidr_block = "${var.cidr-admin}"
        nat_gateway_id = "${aws_vpc_peering_connection.admin.id}"
    }

    route {
        cidr_block = "${var.cidr-elk}"
        nat_gateway_id = "${aws_vpc_peering_connection.elk.id}"
    }


  tags {
    Name        = "${var.tag_project}-rtb-public"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Service     = "${var.tag_service}"
    Role        = "${var.tag_role}"
    Creator     = "${var.tag_creator}"
  }
}

resource "aws_route_table_association" "eu-west-1a-rta-public" {
    subnet_id = "${aws_subnet.eu-west-1a-public.id}"
    route_table_id = "${aws_route_table.public.id}"
}
