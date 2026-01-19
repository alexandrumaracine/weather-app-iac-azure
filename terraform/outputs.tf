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
  value = var.deploy_apps && length(module.backend_app) > 0 ? "https://${module.backend_app[0].ingress_fqdn}" : null
}

output "frontend_url" {
  value = var.deploy_apps && length(module.frontend_app) > 0 ? "https://${module.frontend_app[0].ingress_fqdn}" : null
}
