output "region" {
  value = "${var.region}"
}

output "vpc_id" {
    value = "${aws_vpc.default.id}"
}
output "vpc_cidr" {
    value = "${var.vpc_cidr}"
}
#################################################
# Outputs
output "asg_launchconfig_id" {
  value = "${aws_launch_configuration.default.id}"
}
