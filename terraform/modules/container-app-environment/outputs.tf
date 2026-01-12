output "id" {
  description = "Container App Environment ID"
  value       = azurerm_container_app_environment.this.id
}

output "name" {
  description = "Container App Environment name"
  value       = azurerm_container_app_environment.this.name
}

output "default_domain" {
  description = "Default domain for Container Apps"
  value       = azurerm_container_app_environment.this.default_domain
}
