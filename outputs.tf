# Bloco para exibir o IP público da instância após a criação
output "instance_public_ip" {
  description = "IP público da instância"
  value       = google_compute_instance.web_server.network_interface[0].access_config[0].nat_ip
}

output "website_url" {
  description = "URL do site provisionado."
  value       = "http://${google_compute_instance.web_server.network_interface[0].access_config[0].nat_ip}"
}