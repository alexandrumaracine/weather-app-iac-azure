output "acr_login_server" {
  value = module.acr.login_server
}

output "mysql_host" {
  value = module.mysql.fqdn
}

output "mysql_database" {
  value = module.mysql.database_name
}

output "mysql_user" {
  value = "${var.mysql_admin_user}@${module.mysql.server_name}"
}

output "backend_url" {
  value = var.deploy_apps ? "https://${azurerm_container_app.backend[0].ingress[0].fqdn}" : null
  
}

output "frontend_url" {
  value = var.deploy_apps ? "https://${azurerm_container_app.frontend[0].ingress[0].fqdn}" : null
}