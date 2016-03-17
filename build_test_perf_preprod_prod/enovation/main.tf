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
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}
module "rds" {
  source = "../rds"
  aws_key_name="eurostar"
  aws_key_path="${var.aws_key_path}"
  tag_environment="${var.tag_environment}"
  tag_project="${var.tag_project}"
  tag_service="${var.service}"
  tag_role="${var.tag_role}"
  tag_creator="${var.tag_creator}"
  tag_servicecriticality="${var.tag_servicecriticality}"
  tag_supportcontact="${var.tag_supportcontract}"
  tag_department="${var.tag_department}"
  tag_environment="${var.tag_environment}"
  db_allocated_storage="${var.db_allocated_storage}"
  db_instance_class="${var.db_instance_class}"
  db_instance_count="${var.db_instasnce_count}
  db_multi_az="${var.db_multi_az}"
  db_vpc_cidr="${var.vpc-cidr}"
  db_private_subnet_cidr_1a="${var.db_private_subnet_cidr_1a}"
  db_private_subnet_cidr_1b="${var.db_private_subnet_cidr_1b}"
  database_name="${var.database_name}""
  db_username="${var.db_username}""
  db_password="${var.db_password}""
  db_skip_final_snapshot="${var.db_skip_final_snapshot}"
  db_encryption="${var.db_encryption}"
}
