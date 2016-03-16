variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}
variable "vpc_domain_name" {
  description = "AWS Route53 Domain Name. Must exist! Eg. test.service.beta.eurostar.com"
}
variable "vpc_domain_name_servers" {}
variable "vpc_cidr" {}
variable "public_subnet_cidr_1a" {}
variable "public_subnet_cidr_1b" {}
variable "private_subnet_cidr_1a" {}
variable "private_subnet_cidr_1b" {}

#variable "peer_owner_id" {
#  description = "AWS account ID of the owner of the peer VPC. Default = 012345678901"
#}
#variable "db_vpc_cidr" {
#    description = "CIDR for the whole VPC. Eg. 10.100.0.0/16"
#}

################################################
# Tags
variable "tag_department" {}
variable "tag_environment" {}
variable "tag_project" {}
variable "tag_role" {}
variable "tag_creator" {}
variable "tag_service" {}
variable "tag_servicecriticality" {}
variable "tag_supportcontact" {}

################################################
# Outputs from other modules
#variable "db_vpc_id" {}
#variable "db_main_rtb_id" {}
#variable "db_security_group_id" {}
#variable "ec2_vpc_id" {}
#variable "ec2_rtb_id_1a" {}
#variable "ec2_rtb_id_1b" {}
