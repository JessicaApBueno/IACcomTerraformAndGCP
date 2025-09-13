variable "meu_ip_publico" {
  type        = string
  description = "Endereço IP público para a regra de firewall SSH"
  # IMPORTANTE: Substitua pelo seu endereço IP público no formato CIDR
  # Para saber o seu IP público, acesse https://www.whatismyip.com/ e adicione /32 ao final
  default = "203.0.113.25/32"
}