output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "mysql_host" {
  value = azurerm_mysql_flexible_server.mysql.fqdn
}

output "mysql_database" {
  value = azurerm_mysql_flexible_database.db.name
}

output "mysql_user" {
  value = "${var.mysql_admin_user}@${azurerm_mysql_flexible_server.mysql.name}"
}

output "backend_url" {
  value = var.deploy_apps ? "https://${azurerm_container_app.backend[0].ingress[0].fqdn}" : null
  
}

output "frontend_url" {
  value = var.deploy_apps ? "https://${azurerm_container_app.frontend[0].ingress[0].fqdn}" : null
}
