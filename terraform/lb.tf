# Load balancer
## HTTP Health Check
## Target Pool
## Forwarding Rule

# Define http health check
resource "google_compute_http_health_check" "health-check" {
  name = "hc"

  check_interval_sec = 5
  timeout_sec        = 5

  request_path = "/"
  port         = "9292"
}

# Define target pool
resource "google_compute_target_pool" "reddit-pool" {
  name = "reddit-pool"

  instances = [
    "${google_compute_instance.app.self_link}",
    "${google_compute_instance.app2.self_link}",
  ]

  health_checks = [
    "${google_compute_http_health_check.health-check.self_link}",
  ]
}

# Define forwarding rule 
resource "google_compute_forwarding_rule" "reddit-lb-forwarding-rule" {
  name = "reddit-lb-forwarding-rule"

  target     = "${google_compute_target_pool.reddit-pool.self_link}"
  port_range = "9292"
}

resource "google_compute_instance" "app2" {
  name         = "reddit-app2"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["reddit-app"]

  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  network_interface {
    network       = "default"
    access_config = {}
  }

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }

  connection {
    type        = "ssh"
    user        = "appuser"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }
}
