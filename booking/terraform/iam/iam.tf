#################################################
# Microservice IAM Roles - Instance Profiles
#################################################
# Managed Policies
resource "aws_iam_policy" "s3-policy" {
  name = "${var.tag_service}-${var.tag_environment}-iam-s3-policy-v${var.buildnum}"
  path = "/"
  description = "Common S3 Policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DescribeTags*",
        "s3:Get*",
        "s3:List*"      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# Attach to ALL Roles
resource "aws_iam_policy_attachment" "s3-policy-attach" {
  name = "s3-policy-attach"
  roles = [
    "${aws_iam_role.gateway.name}", 
    "${aws_iam_role.shared-storage.name}", 
    "${aws_iam_role.message-broker.name}", 
    "${aws_iam_role.frontend.name}",
    "${aws_iam_role.app-server.name}"
  ]
  policy_arn = "${aws_iam_policy.s3-policy.arn}"
}

# Gateway
/*resource "aws_iam_role_policy" "gateway" {
  name = "${var.tag_service}-${var.tag_environment}-gateway-iam-role-policy"
  role = "${aws_iam_role.gateway.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DescribeTags*",
        "s3:Get*",
        "s3:List*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}*/

resource "aws_iam_role" "gateway" {
  name = "${var.tag_service}-${var.tag_environment}-gateway-iam-role-v${var.buildnum}"
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
  name = "${var.tag_service}-${var.tag_environment}-gateway-iam-instance-profile-${aws_iam_role.gateway.unique_id}"
  roles = ["${aws_iam_role.gateway.name}"]
}

#################################################
# Frontend
/*resource "aws_iam_role_policy" "frontend" {
  name = "${var.tag_service}-${var.tag_environment}-frontend-iam-role-policy"
  role = "${aws_iam_role.frontend.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DescribeTags*",
        "s3:Get*",
        "s3:List*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}*/

resource "aws_iam_role" "frontend" {
  name = "${var.tag_service}-${var.tag_environment}-frontend-iam-role-v${var.buildnum}"
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

resource "aws_iam_instance_profile" "frontend" {
  name = "${var.tag_service}-${var.tag_environment}-frontend-iam-instance-profile-${aws_iam_role.frontend.unique_id}"
  roles = ["${aws_iam_role.frontend.name}"]
}

#################################################
# Application Server
/*resource "aws_iam_role_policy" "app-server" {
  name = "${var.tag_service}-${var.tag_environment}-app-server-iam-role-policy"
  role = "${aws_iam_role.app-server.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DescribeTags*",
        "s3:Get*",
        "s3:List*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}*/

resource "aws_iam_role" "app-server" {
  name = "${var.tag_service}-${var.tag_environment}-app-server-iam-role-v${var.buildnum}"
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
  name = "${var.tag_service}-${var.tag_environment}-app-server-iam-instance-profile-${aws_iam_role.app-server.unique_id}"
  roles = ["${aws_iam_role.app-server.name}"]
}

#################################################
# Message Broker - ActiveMQ Server
/*resource "aws_iam_role_policy" "message-broker" {
  name = "${var.tag_service}-${var.tag_environment}-message-broker-iam-role-policy"
  role = "${aws_iam_role.message-broker.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DescribeTags*",
        "s3:Get*",
        "s3:List*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}*/

resource "aws_iam_role" "message-broker" {
  name = "${var.tag_service}-${var.tag_environment}-message-broker-iam-role-v${var.buildnum}"
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
  name = "${var.tag_service}-${var.tag_environment}-message-broker-iam-instance-profile-${aws_iam_role.message-broker.unique_id}"
  roles = ["${aws_iam_role.message-broker.name}"]
}

#################################################
# Shared Storage - GlusterFS Server
/*resource "aws_iam_role_policy" "shared-storage" {
  name = "${var.tag_service}-${var.tag_environment}-shared-storage-iam-role-policy"
  role = "${aws_iam_role.shared-storage.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DescribeTags*",
        "s3:Get*",
        "s3:List*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}*/


resource "aws_iam_role" "shared-storage" {
  name = "${var.tag_service}-${var.tag_environment}-shared-storage-iam-role-v${var.buildnum}"
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
  name = "${var.tag_service}-${var.tag_environment}-shared-storage-iam-instance-profile-${aws_iam_role.shared-storage.unique_id}"
  roles = ["${aws_iam_role.shared-storage.name}"]
}

#################################################
# Outputs
output "ec2_iam_ip_gw" {
  value = "${aws_iam_instance_profile.gateway.name}"
}

output "ec2_iam_ip_fe" {
  value = "${aws_iam_instance_profile.frontend.name}"
}

output "ec2_iam_ip_as" {
  value = "${aws_iam_instance_profile.app-server.name}"
}

output "ec2_iam_ip_mb" {
  value = "${aws_iam_instance_profile.message-broker.name}"
}

output "ec2_iam_ip_ss" {
  value = "${aws_iam_instance_profile.shared-storage.name}"
}
