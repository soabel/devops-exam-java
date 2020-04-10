provider "google" {
  version = "3.5.0"

#   credentials = file("<NAME>.json")
  credentials = file("credentials.json")

#   project = "<PROJECT_ID>"
  project = var.project
  region  = var.region
  zone    = var.zone
}