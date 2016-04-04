# General
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_key_path" {}
variable "aws_key_name" {}

variable "region" {
    description = "EC2 Region for the VPC"
    default = "eu-west-1"
}

variable "peer_owner_id" {}

variable "db_vpc_id" {}

variable "aws_region" {
    description = "EC2 Region for the VPC"
    default = "eu-west-1"
}

variable "aws_nat_ami" {
    default = {
        eu-west-1 = "ami-c0993ab3"
    }
}

variable "db-endpoint" {}

variable "ami_frontend" {}


variable "ami_appserver" {}

variable "ami_amq" {}

variable "vpc_cidr" {}

variable "public_subnet_cidr_1a" {}
variable "public_subnet_cidr_1b" {}

variable "private_subnet_cidr_1a" {}

variable "private_subnet_cidr_1b" {}

variable "availability_zones" {
  default = "eu-west-1a,eu-west-1b"
  description = "List of availability zones, use AWS CLI to find your "
}

variable "instance_type" {
  default = "t2.micro"
  description = "AWS instance type"
}

variable "asg_min" {
  description = "Min numbers of servers in ASG"
  default = "1"
}

variable "asg_max" {
  description = "Max numbers of servers in ASG"
  default = "1"
}

variable "asg_desired" {
  description = "Desired numbers of servers in ASG"
  default = "1"
}

variable "tag_environment" {}
variable "tag_project" {}
variable "tag_service" {}
variable "tag_creator" {}

# REQUIRED FOR PEERING TO ADMIN VPC - START
variable "peer_owner_id" {
  description = "AWS account ID of the owner of the peer VPC"
  default = "018274991670"
}

variable "peer_vpc_id" {
  description = "Peer Microservice VPC with ADMIN-VPC-evo-dotcom"
  default = "vpc-3cd9b759"
}

variable "cidr-admin" {
  description = "CIDR for ADMIN-VPC-evo-dotcom"
  default = "10.101.0.0/16"
}

variable "route-table-adminvpn" {
  description = "Route Table for Admin VPC used for VPN access"
  default = "rtb-06347963"
}

variable "route-table-adminvpn-unknown1" {
  description = "Route Table for Admin VPC used for VPN access"
  default = "rtb-b12865d4"
}

variable "route-table-adminvpn-unknown2" {
  description = "Route Table for Admin VPC used for VPN access"
  default = "rtb-b32865d6"
}

variable "route-table-adminvpn-unknown3" {
  description = "Route Table for Admin VPC used for VPN access"
  default = "rtb-440c4421"
}
# REQUIRED FOR PEERING TO ADMIN VPC - END

# RDS variables

#var.tag_servicecriticality {}
#var.tag_supportcontact {}
variable "tag_department" {}
variable "tag_environment" {}

# REQUIRED FOR PEERING TO ELK VPC - START

variable "peer_vpc_id_elk" {
  description = "Peer Microservice VPC with ELK-VPC ID"
  default = "vpc-bcb69cd9"
}

variable "buildnum" {}

variable "cidr-elk" {
  description = "CIDR for ELK-routetable"
  default = "10.165.80.0/20"
}

variable "route-table-elk" {
  description = "Route Table for ELK VPC"
  default = "rtb-d66974b3"
}

variable "domain_name_servers" {}

variable "db_vpc_cidr" {}

# REQUIRED FOR PEERING TO ELK VPC - END


variable "domain" {
  description = "Top level domain to use; trainz.io or eurostar.com"
  default = "trainz.io"
}

variable "aws_route53_zone" {
  default = "Z2R7EXT83GFAR6" #trainz.io.
#  default = "Z2GNWE02RWX8RO" #prod.aws.trainz.io.
}

variable "snap_cname" {
  description = "cname for main elb endpoint snap_cname+tag_environment"
  default = "snap"
}
