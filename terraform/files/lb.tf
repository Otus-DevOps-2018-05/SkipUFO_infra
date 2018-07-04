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

  count = "${var.instance_count}"

  instances = [
    "${google_compute_instance.app.self_link}",
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

variable instance_count {
  description = "Instance count"
  default     = 1
}

variable template_disk_image {
  description = "Template disk image family"
  default     = "reddit-full"
}

resource "google_compute_instance_template" "reddit-app-template" {
  name         = "reddit-app"
  machine_type = "g1-small"
  tags         = ["reddit-app"]

  disk {
    source_image = "reddit-full"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network       = "default"
    access_config = {}
  }
}

resource "google_compute_instance_group_manager" "reddit-app-group-manager" {
  name               = "reddit-app-group-manager"
  base_instance_name = "reddit-base"
  instance_template  = "${google_compute_instance_template.reddit-app-template.self_link}"
  target_pools       = ["${google_compute_target_pool.reddit-pool.self_link}"]
  zone               = "europe-west1-b"
  target_size        = "${var.instance_count}"

  auto_healing_policies {
    health_check      = "${google_compute_http_health_check.health-check.self_link}"
    initial_delay_sec = 300
  }
}

output "lb_ip" {
  value = "${google_compute_forwarding_rule.reddit-lb-forwarding-rule.ip_address}"
}
