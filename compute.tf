# Cria a instância (VM) no Compute Engine
resource "google_compute_instance" "web_server" {
  name         = "webserver-dvp"
  machine_type = "e2-micro"      # Equivalente ao t2.micro da AWS
  zone         = "us-central1-a"

  # Aplica as regras de firewall que criamos
  tags = ["web-server"]

  # Define o disco de boot com a imagem Debian
  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian.self_link
    }
  }

  # Configura a rede e solicita um IP público
  network_interface {
    network = "default"
    access_config {
      // Bloco vazio para atribuir um IP público efêmero
    }
  }

  # Adiciona a nossa chave pública à instância para permitir o acesso SSH
  metadata = {
    ssh-keys = "devops:${tls_private_key.rsa_key.public_key_openssh}"
  }
}