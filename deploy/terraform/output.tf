output "endpoint" {
  value = "${google_container_cluster.primary.endpoint}"
}

output "master_version" {
  value = "${google_container_cluster.primary.master_version}"
}

output "ip" {
  value = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
}