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
# Outputs frontend
output "asg_launchconfig_id" {
  value = "${aws_launch_configuration.frontend.id}"
}
# Outputs backend
output "asg_launchconfig_id" {
  value = "${aws_launch_configuration.backend.id}"
}
