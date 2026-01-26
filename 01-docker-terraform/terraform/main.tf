terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.18.0"
    }
  }
}

provider "google" {
  credentials = file("my-creds.json")
  project     = "eng-district-485200-n2"
  region      = "us-central1"
}

resource "google_storage_bucket" "demo-bucket" {
  name          = "eng-district-485200-n2-terra-bucket"
  location      = "US"
  force_destroy = true
}

resource "google_bigquery_dataset" "demo_dataset" {
  dataset_id = "demo_dataset"
  location   = "US"
}