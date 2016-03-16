variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_key_path" {}
variable "aws_key_name" {}
variable "aws_region" { default = "us-west-2" }
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

variable "tag_db_role" {}

variable "db_skip_final_snapshot" {}
