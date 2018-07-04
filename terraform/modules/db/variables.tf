variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable zone {
  description = "Zone"
  default     = "europe-west1-b"
}

variable db_disk_image {
  description = "Disk image with db for reddit app"
  default     = "reddit-db"
}

variable machine_type {
  description = "Machine type"
  default     = "g1-small"
}
