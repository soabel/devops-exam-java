resource "google_container_cluster" "primary" {
  name        = "${var.cluster-name}"
  project     = "${var.project}"
  description = "${var.cluster-description}"
  location    = "${var.region}"

  remove_default_node_pool = true
  initial_node_count = "${var.node_count}"

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.cluster-name}-node-pool"
  project     = "${var.project}"
  location   = "${var.region}"
  cluster    = "${google_container_cluster.primary.name}"
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "${var.machine_type}"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}