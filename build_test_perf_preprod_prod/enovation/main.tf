# Copyright 2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file
# except in compliance with the License. A copy of the License is located at
#
#     http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is distributed on an "AS IS"
# BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under the License.
# Provider
# Provider
provider "aws" {
  access_key = "AKIAIWN36OUFA3EP4Z3Q" 
  secret_key = "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"
  region     = "eu-west-1" 
}
module "rds" {
  source = "../rds"
  aws_key_name="eurostar"
  aws_key_path="~/.ssh/eurostar-aws-dev.pem"
  tag_environment="test"
  tag_project="microservices"
  tag_service="Enovation_Microservice"
  tag_role="enovation-db"
  tag_creator="terraform"
  tag_servicecriticality="Low"
  tag_supportcontact="Digital Systems"
  tag_department="Digital Systems"
  tag_environment="integration"
  db_allocated_storage="5"
  db_instance_class="db.t2.micro"
  db_instance_count="1"
  db_multi_az="false"
  db_vpc_cidr="10.38.120.0/26"
  db_private_subnet_cidr_1a="10.38.120.0/28"
  db_private_subnet_cidr_1b="10.38.120.16/28"
  database_name="enovation"
  db_username="enovationadmin"
  db_password="Enovation!"
  db_skip_final_snapshot="false"
  db_encryption="false"
  aws_route53_zone_id="Z2R7EXT83GFAR6"
}
