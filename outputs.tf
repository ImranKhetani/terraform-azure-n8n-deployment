output "n8n_dns_name" {
  value = azurerm_public_ip.n8n_public_ip.fqdn
}