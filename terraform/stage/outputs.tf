output "app_external_ip" {
  value = "${module.app.external_ip}"
}

output "db_internal_ip" {
  value = "${module.db.internal_ip}"
}
