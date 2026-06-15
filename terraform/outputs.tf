output "app_gateway_public_ip" {
  description = "Public IP of the Application Gateway"
  value       = module.app_gateway.public_ip_address
}

output "container_app_fqdn" {
  description = "FQDN of the Container App"
  value       = module.container_app.container_app_fqdn
}

output "resource_group_name" {
  description = "Resource Group name"
  value       = azurerm_resource_group.main.name
}
