# Gera uma chave privada RSA de 4096 bits
resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Salva a chave privada em um arquivo local
resource "local_file" "private_key_pem" {
  content         = tls_private_key.rsa_key.private_key_pem
  filename        = "${path.module}/gcp-instance-key.pem"
  # Define as permissões do arquivo para que apenas o proprietário possa ler
  file_permission = "0400"
}