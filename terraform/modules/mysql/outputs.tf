output "server_name" {
  description = "MySQL server name"
  value       = azurerm_mysql_flexible_server.this.name
}

output "fqdn" {
  description = "MySQL server FQDN"
  value       = azurerm_mysql_flexible_server.this.fqdn
}

output "database_name" {
  description = "MySQL database name"
  value       = azurerm_mysql_flexible_database.this.name
}
