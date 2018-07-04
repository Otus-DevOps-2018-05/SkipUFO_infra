terraform {
  backend "gcs" {
    bucket = "${var.project}-storage-bucket-stage"
    prefix = "terraform/state"
  }
}
