# 1. Regra de Firewall para liberar a porta 80 (HTTP) para qualquer origem
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = "default" # Usa a rede VPC padrão

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
}

# 2. Regra de Firewall para liberar a porta 22 (SSH) para um IP específico
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh-from-my-ip"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [var.meu_ip_publico]
  target_tags   = ["web-server"]
}