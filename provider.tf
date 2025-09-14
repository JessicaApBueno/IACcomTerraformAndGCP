terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "MeuProjetoID" # <-- SUBSTITUA PELO ID DO SEU PROJETO
  region  = "us-central1"
  zone    = "us-central1-a"
}
