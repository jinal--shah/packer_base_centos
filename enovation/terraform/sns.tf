# SNS (AWS Simple Notification Service)
# - https://docs.aws.amazon.com/sns/latest/dg/GettingStarted.html

resource "aws_sns_topic" "enovation" {
  name = "${var.tag_project}-${var.tag_environment}"
}

# Manually add email addresses for notifications: https://eu-west-1.console.aws.amazon.com/sns
#https://www.terraform.io/docs/providers/aws/r/sns_topic_subscription.html
#These are unsupported because the endpoint needs to be authorized and does not generate an ARN until the target email address has been validated. This breaks the Terraform model and as a result are not currently supported.
#resource "aws_sns_topic_subscription" "enovation_target" {
#  topic_arn = "${aws_sns_topic.enovation.arn}"
#  protocol  = "email"
#  endpoint  = "${var.notification_email_addresses}"
#}
