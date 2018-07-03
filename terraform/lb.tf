# Load balancer
## HTTP Health Check
## Target Pool
## Forwarding Rule

# Define http health check
resource "google_compute_http_health_check" "health-check" {
  name = "hc"

  request_path = "/"
  port         = "9292"
}

# Define target pool
resource "google_compute_target_pool" "reddit-pool" {
  name = "reddit-pool"

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
