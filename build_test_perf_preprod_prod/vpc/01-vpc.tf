#################################################
# Microservice VPC - EC2
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
  cidr_block = "${var.vpc_cidr}"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags {
    Name        = "${var.tag_project}-${var.tag_environment}-vpc"
    Build       = "Automatic"
    Creator     = "${var.tag_creator}"    
    Department  = "${var.tag_department}"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Service     = "${var.tag_service}"
    ServiceCriticality  = "${var.tag_servicecriticality}"
    SupportContact      = "${var.tag_supportcontact}"
  }
}
#################################################
# IGW
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name        = "${var.tag_project}-${var.tag_environment}-igw"
    Build       = "Automatic"
    Creator     = "${var.tag_creator}"    
    Department  = "${var.tag_department}"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Service     = "${var.tag_service}"
    ServiceCriticality  = "${var.tag_servicecriticality}"
    SupportContact      = "${var.tag_supportcontact}"
  }
}

#################################################
# DHCP Options
resource "aws_vpc_dhcp_options" "default" {
  domain_name = "${var.vpc_domain_name}"
  domain_name_servers = ["${var.vpc_domain_name_servers}"]

  tags {
    Name        = "${var.tag_project}-${var.tag_environment}-dopt"
    Build       = "Automatic"
    Creator     = "${var.tag_creator}"    
    Department  = "${var.tag_department}"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Service     = "${var.tag_service}"
    ServiceCriticality  = "${var.tag_servicecriticality}"
    SupportContact      = "${var.tag_supportcontact}"
  }
}

resource "aws_vpc_dhcp_options_association" "default" {
  vpc_id = "${aws_vpc.default.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.default.id}"
}

#################################################
# Public Subnets
resource "aws_subnet" "public-subnet-1a" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.public_subnet_cidr_1a}"
  availability_zone = "eu-west-1a"

  tags {
    Name        = "${var.tag_project}-${var.tag_environment}-public-subnet-1a"
    Build       = "Automatic"
    Creator     = "${var.tag_creator}"    
    Department  = "${var.tag_department}"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Service     = "${var.tag_service}"
    ServiceCriticality  = "${var.tag_servicecriticality}"
    SupportContact      = "${var.tag_supportcontact}"
  }
}

resource "aws_subnet" "public-subnet-1b" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.public_subnet_cidr_1b}"
  availability_zone = "eu-west-1b"

  tags {
    Name        = "${var.tag_project}-${var.tag_environment}-public-subnet-1b"
    Build       = "Automatic"
    Creator     = "${var.tag_creator}"    
    Department  = "${var.tag_department}"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Service     = "${var.tag_service}"
    ServiceCriticality  = "${var.tag_servicecriticality}"
    SupportContact      = "${var.tag_supportcontact}"
  }
}

#################################################
# Private Subnets
resource "aws_subnet" "private-subnet-1a" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.private_subnet_cidr_1a}"
  availability_zone = "eu-west-1a"

  tags {
    Name        = "${var.tag_project}-${var.tag_environment}-private-subnet-1a"
    Build       = "Automatic"
    Creator     = "${var.tag_creator}"    
    Department  = "${var.tag_department}"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Service     = "${var.tag_service}"
    ServiceCriticality  = "${var.tag_servicecriticality}"
    SupportContact      = "${var.tag_supportcontact}"
  }
}

resource "aws_subnet" "private-subnet-1b" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.private_subnet_cidr_1b}"
  availability_zone = "eu-west-1b"

  tags {
    Name        = "${var.tag_project}-${var.tag_environment}-private-subnet-1b"
    Build       = "Automatic"
    Creator     = "${var.tag_creator}"    
    Department  = "${var.tag_department}"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Service     = "${var.tag_service}"
    ServiceCriticality  = "${var.tag_servicecriticality}"
    SupportContact      = "${var.tag_supportcontact}"
  }
}

#################################################
# NAT Gateways
resource "aws_eip" "eip-nat-1a" {
  vpc = "true"
}

resource "aws_eip" "eip-nat-1b" {
  vpc = "true"
}

resource "aws_nat_gateway" "nat-1a" {
  allocation_id = "${aws_eip.eip-nat-1a.id}"
  subnet_id = "${aws_subnet.public-subnet-1a.id}"

  depends_on = ["aws_internet_gateway.default"]
}

resource "aws_nat_gateway" "nat-1b" {
  allocation_id = "${aws_eip.eip-nat-1b.id}"
  subnet_id = "${aws_subnet.public-subnet-1b.id}"

  depends_on = ["aws_internet_gateway.default"]  
}


#################################################
# Route Tables
resource "aws_route_table" "public-route" {
  vpc_id = "${aws_vpc.default.id}"
  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name        = "${var.tag_project}-${var.tag_environment}-public-route"
    Build       = "Automatic"
    Creator     = "${var.tag_creator}"    
    Department  = "${var.tag_department}"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Service     = "${var.tag_service}"
    ServiceCriticality  = "${var.tag_servicecriticality}"
    SupportContact      = "${var.tag_supportcontact}"
  }  
}

resource "aws_route_table" "private-route-1a" {
  vpc_id = "${aws_vpc.default.id}"
  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.nat-1a.id}"
  }

  tags {
    Name        = "${var.tag_project}-${var.tag_environment}-private-route-1a"
    Build       = "Automatic"
    Creator     = "${var.tag_creator}"    
    Department  = "${var.tag_department}"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Service     = "${var.tag_service}"
    ServiceCriticality  = "${var.tag_servicecriticality}"
    SupportContact      = "${var.tag_supportcontact}"
  }  
}

resource "aws_route_table" "private-route-1b" {
  vpc_id = "${aws_vpc.default.id}"
  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.nat-1b.id}"
  }

  tags {
    Name        = "${var.tag_project}-${var.tag_environment}-private-route-1b"
    Build       = "Automatic"
    Creator     = "${var.tag_creator}"    
    Department  = "${var.tag_department}"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Service     = "${var.tag_service}"
    ServiceCriticality  = "${var.tag_servicecriticality}"
    SupportContact      = "${var.tag_supportcontact}"
  }  
}

resource "aws_route_table_association" "pub-rtb-1a-association" {
  subnet_id = "${aws_subnet.public-subnet-1a.id}"
  route_table_id = "${aws_route_table.public-route.id}"
}

resource "aws_route_table_association" "pub-rtb-1b-association" {
  subnet_id = "${aws_subnet.public-subnet-1b.id}"
  route_table_id = "${aws_route_table.public-route.id}"
}

resource "aws_route_table_association" "pri-rtb-1a-association" {
  subnet_id = "${aws_subnet.private-subnet-1a.id}"
  route_table_id = "${aws_route_table.private-route-1a.id}"
}

resource "aws_route_table_association" "pri-rtb-1b-association" {
  subnet_id = "${aws_subnet.private-subnet-1b.id}"
  route_table_id = "${aws_route_table.private-route-1b.id}"
}

#################################################
# Outputs
output "ec2_vpc_id" {
  value = "${aws_vpc.default.id}"
}

output "ec2_eip_nat_pub_1a" {
  value = "${aws_eip.eip-nat-1a.public_ip}"
}

output "ec2_eip_nat_pub_1b" {
  value = "${aws_eip.eip-nat-1b.public_ip}"
}

output "ec2_rtb_id_1a" {
  value = "${aws_route_table.private-route-1a.id}"
}

output "ec2_rtb_id_1b" {
  value = "${aws_route_table.private-route-1b.id}"
}

output "ec2_vpc_pub_sn_1a" {
  value = "${aws_subnet.public-subnet-1a.id}"
}

output "ec2_vpc_pub_sn_1b" {
  value = "${aws_subnet.public-subnet-1b.id}"
}

output "ec2_vpc_pri_sn_1a" {
  value = "${aws_subnet.private-subnet-1a.id}"
}

output "ec2_vpc_pri_sn_1b" {
  value = "${aws_subnet.private-subnet-1b.id}"
}