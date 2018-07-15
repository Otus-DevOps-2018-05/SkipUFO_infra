terraform {
  backend "gcs" {
    bucket = "organic-diode-207603-storage-bucket-stage"
    prefix = "terraform/state"
  }
}
