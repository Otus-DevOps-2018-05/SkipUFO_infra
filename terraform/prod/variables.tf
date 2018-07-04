variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  default     = "europe-west1"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable disk_image {
  description = "Disk image"
}

variable private_key_path {
  description = "Path to the private key used for ssh access"
}

variable zone {
  description = "Zone"
  default     = "europe-west1-b"
}

variable ssh_credentials {
  description = "List of ssh credentials for project (wide) ssh connections (<appuser>:<ssh-pub-key>)"
  type        = "list"
  default     = []
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}

variable db_disk_image {
  description = "Disk image with db for reddit app"
  default     = "reddit-db"
}

variable app_machine_type {
  description = "Machine type for reddit app"
  default     = "g1-small"
}

variable db_machine_type {
  description = "Machine type for reddit db"
  default     = "g1-small"
}
