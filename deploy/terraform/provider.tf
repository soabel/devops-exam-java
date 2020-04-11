provider "google" {
  version = "3.5.0"
  credentials = file(var.credentials)
  project = var.project
  region  = var.region
  zone    = var.zone
}