# TFState to S3
resource "terraform_remote_state" "tfstate" {
  backend = "s3"
  config {
    bucket = "eurostar-terraform-state-${var.tag_environment}"
    key = "${var.tag_service}/vpc.tfstate"
    region = "eu-west-1"
  }
}
