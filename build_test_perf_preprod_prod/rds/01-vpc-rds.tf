#################################################
# Microservice VPC - RDS
#################################################
variable "aws_key_path" {}
variable "aws_key_name" {}
variable "db_vpc_cidr" {
    description = "CIDR for the whole VPC. Eg. 10.100.0.0/16"
}
variable "db_private_subnet_cidr_1a" {
    description = "CIDR for the Private Subnet in AZ1. Eg. 10.100.3.0/24"
}
variable "db_private_subnet_cidr_1b" {
    description = "CIDR for the Private Subnet in AZ2. Eg. 10.100.4.0/24"
}
variable "availability_zones" {
  default = "eu-west-1a,eu-west-1b,eu-west-1c"
  description = "List of availability zones, use AWS CLI to find your "
}

variable "tag_department" {}
variable "tag_environment" {}
variable "tag_project" {}
variable "tag_role" {}
variable "tag_creator" {}
variable "tag_service" {}
variable "tag_servicecriticality" {}
variable "tag_supportcontact" {}

# RDS
variable "aws_route53_zone_id" {
  description = "AWS Route53 Hosted Zone ID. Must exist! Eg. Z123456ABCDEF"
}

variable "db_allocated_storage" {
  description = "AWS RDS allocated storage in Gigabytes. Eg. Min = 5"
}

variable "db_encryption" {
  description = "AWS RDS Encryption. Boolean. Eg. db.t2.micro = false; db.r3.xlarge = true"
}

variable "db_instance_class" {
  default = "db.t2.micro"
  description = "AWS RDS instance class. Use db.t2.micro for non-prod envs."
}

variable "db_instance_count" {
  description = "AWS RDS instance count/number. Eg. 1 for db1; 2 for db2"
}

variable "db_multi_az" {
  description = "AWS RDS multi AZ. Boolean. Non-prod = false"
}

variable "db_password" {
  description = "AWS RDS admin password."
}

variable "database_name" {
  description = "The name of the DB for the Microservice"
}

variable "db_username" {
  description = "AWS RDS admin username."
}


variable "db_skip_final_snapshot" {}
#################################################
# VPC
resource "aws_vpc" "default" {
  cidr_block = "${var.db_vpc_cidr}"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags {
    Name        = "${var.tag_project}-${var.tag_environment}-db-vpc"
    Build       = "Automatic"
    Creator     = "${var.tag_creator}"
    Department  = "${var.tag_department}"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Role        = "${var.tag_role}"
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
    Name        = "${var.tag_project}-${var.tag_environment}-db-igw"
    Build       = "Automatic"
    Creator     = "${var.tag_creator}"
    Department  = "${var.tag_department}"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Role        = "${var.tag_role}"
    Service     = "${var.tag_service}"
    ServiceCriticality  = "${var.tag_servicecriticality}"
    SupportContact      = "${var.tag_supportcontact}"
  }
}

#################################################
# Private Subnets
resource "aws_subnet" "db-private-subnet-1a" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.db_private_subnet_cidr_1a}"
  availability_zone = "eu-west-1a"

  tags {
    Name        = "${var.tag_project}-${var.tag_environment}-db-private-subnet-1a"
    Build       = "Automatic"
    Creator     = "${var.tag_creator}"
    Department  = "${var.tag_department}"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Role        = "${var.tag_role}"
    Service     = "${var.tag_service}"
    ServiceCriticality  = "${var.tag_servicecriticality}"
    SupportContact      = "${var.tag_supportcontact}"
  }
}

resource "aws_subnet" "db-private-subnet-1b" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.db_private_subnet_cidr_1b}"
  availability_zone = "eu-west-1b"

  tags {
    Name        = "${var.tag_project}-${var.tag_environment}-db-private-subnet-1b"
    Build       = "Automatic"
    Creator     = "${var.tag_creator}"
    Department  = "${var.tag_department}"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Role        = "${var.tag_role}"
    Service     = "${var.tag_service}"
    ServiceCriticality  = "${var.tag_servicecriticality}"
    SupportContact      = "${var.tag_supportcontact}"
  }
}

#################################################
# Security Group
resource "aws_security_group" "default" {
  name = "${var.tag_project}-${var.tag_environment}-db-sg"
  description = "${var.tag_project}-${var.tag_environment}-db-security group"
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name        = "${var.tag_project}-${var.tag_environment}-db-sg"
    Build       = "Automatic"
    Creator     = "${var.tag_creator}"
    Department  = "${var.tag_department}"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Role        = "${var.tag_role}"
    Service     = "${var.tag_service}"
    ServiceCriticality  = "${var.tag_servicecriticality}"
    SupportContact      = "${var.tag_supportcontact}"
  }

  depends_on = ["aws_vpc.default"]
}

#################################################
# Subnet Group
resource "aws_db_subnet_group" "default" {
  name = "${var.tag_project}-${var.tag_environment}-db-sng"
  description = "${var.tag_project}-${var.tag_environment} DB subnet group"
  subnet_ids = [
    "${aws_subnet.db-private-subnet-1a.id}",
    "${aws_subnet.db-private-subnet-1b.id}"
  ]

  tags {
    Name        = "${var.tag_project}-${var.tag_environment}-db-sng"
    Build       = "Automatic"
    Creator     = "${var.tag_creator}"
    Department  = "${var.tag_department}"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Role        = "${var.tag_role}"
    Service     = "${var.tag_service}"
    ServiceCriticality  = "${var.tag_servicecriticality}"
    SupportContact      = "${var.tag_supportcontact}"
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
