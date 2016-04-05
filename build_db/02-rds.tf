#################################################
# Microservice RDS
#################################################
# DB Parameter Group
resource "aws_db_parameter_group" "default" {
  name  = "${var.tag_service}-${var.tag_environment}-db-${var.db_instance_count}-pg"
  family = "mysql5.6"
  description = "${var.tag_project}-${var.tag_environment} DB parameter group"

  parameter {
    name = "query_cache_size"
    value = "10485760"
  }

  tags {
    Name        = "${var.tag_service}-${var.tag_project}-${var.tag_environment}-db-pg"
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
# RDS DB Instance
resource "aws_db_instance" "default" {
  allocated_storage           = "${var.db_allocated_storage}"
  auto_minor_version_upgrade  = "false"
  backup_retention_period     = "1"
  copy_tags_to_snapshot       = "true"
  db_subnet_group_name        = "${aws_db_subnet_group.default.id}"
  engine                      = "mysql"
  engine_version              = "5.6.22"
  final_snapshot_identifier   = "${var.tag_project}-${var.tag_service}-${var.tag_environment}-db${var.db_instance_count}-final"
  identifier                  = "${var.tag_project}-${var.tag_service}-${var.tag_environment}-db${var.db_instance_count}-id"
  instance_class              = "${var.db_instance_class}"
  multi_az                    = "${var.db_multi_az}"
  name                        = "${var.database_name}"
  parameter_group_name        = "${aws_db_parameter_group.default.id}"
  password                    = "${var.db_password}"
  publicly_accessible         = "false"
  storage_encrypted           = "${var.db_encryption}"
  storage_type                = "gp2"
  username                    = "${var.db_username}"
  vpc_security_group_ids      = ["${aws_security_group.default.id}"]


  tags {
    Name        = "${var.tag_service}-${var.tag_environment}-db"
    Build       = "Automatic"
    Creator     = "${var.tag_creator}"
    Department  = "${var.tag_department}"
    Environment = "${var.tag_environment}"
    Project     = "${var.tag_project}"
    Role        = "Database"
    Service     = "${var.tag_service}"
    ServiceCriticality  = "${var.tag_servicecriticality}"
    SupportContact      = "${var.tag_supportcontact}"
  }

  depends_on = ["aws_db_parameter_group.default"]
}


resource "aws_route53_record" "default" {
   zone_id = "${var.aws_route53_zone_id}"
   name = "db${var.db_instance_count}.${var.tag_environment}.${var.tag_project}.trainz.io"
   type = "CNAME"
   ttl = "60"
   records = ["${aws_db_instance.default.endpoint}"]
}

#################################################
# Outputs
output "db_instance_id" {
  value = "${aws_db_instance.default.id}"
}

output "db_instance_endpoint" {
  value = "${aws_db_instance.default.endpoint}"
}

output "db_fqdn" {
  value = "${aws_route53_record.default.fqdn}"
}
