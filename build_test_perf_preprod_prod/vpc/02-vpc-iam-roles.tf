#################################################
# Microservice IAM Roles - Instance Profiles
#################################################
# Gateway - Bastion
resource "aws_iam_role_policy" "gateway" {
  name = "${var.tag_project}-${var.tag_environment}-gateway-iam-role-policy"
  role = "${aws_iam_role.gateway.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:Get*",
        "s3:List*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "gateway" {
  name = "${var.tag_project}-${var.tag_environment}-gateway-iam-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "gateway" {
  name = "${var.tag_project}-${var.tag_environment}-gateway-iam-instance-profile"
  roles = ["${aws_iam_role.gateway.name}"]
}

#################################################
# Application Server
resource "aws_iam_role_policy" "app-server" {
  name = "${var.tag_project}-${var.tag_environment}-app-server-iam-role-policy"
  role = "${aws_iam_role.app-server.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:Get*",
        "s3:List*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "app-server" {
  name = "${var.tag_project}-${var.tag_environment}-app-server-iam-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "app-server" {
  name = "${var.tag_project}-${var.tag_environment}-app-server-iam-instance-profile"
  roles = ["${aws_iam_role.app-server.name}"]
}

#################################################
# Message Broker - ActiveMQ Server
resource "aws_iam_role_policy" "message-broker" {
  name = "${var.tag_project}-${var.tag_environment}-message-broker-iam-role-policy"
  role = "${aws_iam_role.message-broker.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:Get*",
        "s3:List*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "message-broker" {
  name = "${var.tag_project}-${var.tag_environment}-message-broker-iam-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "message-broker" {
  name = "${var.tag_project}-${var.tag_environment}-message-broker-iam-instance-profile"
  roles = ["${aws_iam_role.message-broker.name}"]
}

#################################################
# Shared Storage - GlusterFS Server
resource "aws_iam_role_policy" "shared-storage" {
  name = "${var.tag_project}-${var.tag_environment}-shared-storage-iam-role-policy"
  role = "${aws_iam_role.shared-storage.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:Get*",
        "s3:List*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_iam_role" "shared-storage" {
  name = "${var.tag_project}-${var.tag_environment}-shared-storage-iam-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "shared-storage" {
  name = "${var.tag_project}-${var.tag_environment}-shared-storage-iam-instance-profile"
  roles = ["${aws_iam_role.shared-storage.name}"]
}

#################################################
# Outputs
output "ec2_iam_ip_gw" {
  value = "${aws_iam_instance_profile.gateway.id}"
}

output "ec2_iam_ip_as" {
  value = "${aws_iam_instance_profile.app-server.id}"
}

output "ec2_iam_ip_mb" {
  value = "${aws_iam_instance_profile.message-broker.id}"
}

output "ec2_iam_ip_ss" {
  value = "${aws_iam_instance_profile.shared-storage.id}"
}