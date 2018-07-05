terraform {
  backend "gcs" {
    bucket = "organic-diode-207603-storage-bucket-prod"
    prefix = "terraform/state"
  }
}
