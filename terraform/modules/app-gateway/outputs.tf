output "public_ip_address" {
  description = "Public IP address of the Application Gateway"
  value       = azurerm_public_ip.main.ip_address
}

output "app_gateway_id" {
  value = azurerm_application_gateway.main.id
}
