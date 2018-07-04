terraform {
  backend "gcs" {
    bucket = "${var.project}-storage-bucket-prod"
    prefix = "terraform/state"
  }
}
