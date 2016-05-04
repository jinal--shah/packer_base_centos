# General
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_key_path" {
  default = "~/.ssh/eurostar.pem"
}
variable "aws_key_name" {
  default = "eurostar"
}

variable "region" {
    description = "EC2 Region for the VPC"
    default = "eu-west-1"
}

variable "aws_region" {
    description = "EC2 Region for the VPC"
    default = "eu-west-1"
}

variable "buildnum" {}

variable "tag_environment" {}
variable "tag_project" {}
variable "tag_service" {}
variable "tag_creator" {}

