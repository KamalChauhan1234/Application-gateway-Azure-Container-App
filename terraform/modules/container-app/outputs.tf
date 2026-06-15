output "container_app_fqdn" {
  description = "FQDN of the Container App (internal)"
  value       = azurerm_container_app.main.ingress[0].fqdn
}

output "container_app_id" {
  value = azurerm_container_app.main.id
}
