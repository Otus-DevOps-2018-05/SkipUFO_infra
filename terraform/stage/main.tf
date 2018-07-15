provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

module "db" {
  source           = "../modules/db"
  public_key_path  = "${var.public_key_path}"
  zone             = "${var.zone}"
  db_disk_image    = "${var.db_disk_image}"
  machine_type     = "${var.db_machine_type}"
  private_key_path = "${var.private_key_path}"
}

module "app" {
  source            = "../modules/app"
  public_key_path   = "${var.public_key_path}"
  zone              = "${var.zone}"
  app_disk_image    = "${var.app_disk_image}"
  machine_type      = "${var.app_machine_type}"
  db_reddit_ip      = "${module.db.internal_ip}"
  private_key_path  = "${var.private_key_path}"
  provision_enabled = true
}

module "vpc" {
  source        = "../modules/vpc"
  source_ranges = ["0.0.0.0/0"]
}
