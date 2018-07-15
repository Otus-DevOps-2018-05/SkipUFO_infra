variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable zone {
  description = "Zone"
  default     = "europe-west1-b"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}

variable machine_type {
  description = "Machine type"
  default     = "g1-small"
}

variable db_reddit_ip {
  description = "Reddit DB Ip Address"
}

variable private_key_path {
  description = "Private key path"
}

variable provision_enabled {
  description = "Whether provision is enabled"
}
