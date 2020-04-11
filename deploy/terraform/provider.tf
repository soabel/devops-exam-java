provider "google" {
  version = "3.5.0"

#   credentials = file("<NAME>.json")
  credentials = file(var.credentials)

#   project = "<PROJECT_ID>"
  project = var.project
  region  = var.region
  zone    = var.zone
}