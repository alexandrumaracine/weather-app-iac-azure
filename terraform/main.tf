locals {
  tags = {
    owner   = var.owner
    project = "SkyCastNow"
  }
}

module "rg" {
  source   = "./modules/resource-group"
  name     = "rg-${var.project_name}"
  location = var.location
  tags     = local.tags
}

module "acr" {
  source              = "./modules/acr"
  name                = "${var.project_name}acr"
  resource_group_name = module.rg.name
  location            = module.rg.location
  tags                = local.tags
}

module "log_analytics" {
  source = "./modules/log-analytics"

  name                = "${var.project_name}-logs"
  location            = module.rg.location
  resource_group_name = module.rg.name

  sku               = "PerGB2018"
  retention_in_days = 30
  tags              = local.tags
}


module "container_app_env" {
  source = "./modules/container-app-environment"

  name                = "${var.project_name}-env"
  location            = module.rg.location
  resource_group_name = module.rg.name

  log_analytics_workspace_id = module.log_analytics.id

  tags = local.tags
}

module "mysql" {
  source = "./modules/mysql"

  project_name         = var.project_name
  resource_group_name  = module.rg.name
  location             = module.rg.location

  admin_username = var.mysql_admin_user
  admin_password = var.mysql_admin_password

  database_name = var.mysql_database

  tags = local.tags
}


# ----------------------------
# Container Apps: Backend
# ----------------------------
module "backend_app" {
  count  = var.deploy_apps ? 1 : 0
  source = "./modules/container-app-backend"

  name                         = var.backend_name
  resource_group_name          = module.rg.name
  container_app_environment_id = module.container_app_env.id
  tags                         = local.tags

  acr_login_server    = module.acr.login_server
  acr_admin_username  = module.acr.admin_username
  acr_admin_password  = module.acr.admin_password
  # acr_password_secret_name stays default "acr-password"

  image = var.backend_image

  openweather_api_key = var.openweather_api_key

  mysql_host     = module.mysql.fqdn
  mysql_database = var.mysql_database
  mysql_user     = var.mysql_admin_user
  mysql_password = var.mysql_admin_password

  # cpu/memory/min/max use defaults matching your current config
}



# Allow backend container app identity to pull from ACR
# resource "azurerm_role_assignment" "backend_acr_pull" {
#   scope                = azurerm_container_registry.acr.id
#   role_definition_name = "AcrPull"
#   principal_id         = azurerm_container_app.backend.identity[0].principal_id
# }

# # ----------------------------
# # Container Apps: Frontend
# # ----------------------------
module "frontend_app" {
  count  = var.deploy_apps ? 1 : 0
  source = "./modules/container-app-frontend"

  name                         = var.frontend_name
  resource_group_name          = module.rg.name
  container_app_environment_id = module.container_app_env.id
  tags                         = local.tags

  acr_login_server   = module.acr.login_server
  acr_admin_username = module.acr.admin_username
  acr_admin_password = module.acr.admin_password

  image = var.frontend_image

  api_base_url = var.deploy_apps ? "https://${module.backend_app[0].ingress_fqdn}" : ""

  command = [
    "sh",
    "-c",
    "echo \"window.RUNTIME_CONFIG={API_BASE_URL:'$API_BASE_URL'};\" > /app/frontend/build/runtime-config.js && serve -s build -l 3000"
  ]
}


# Allow frontend container app identity to pull from ACR
# resource "azurerm_role_assignment" "frontend_acr_pull" {
#   scope                = azurerm_container_registry.acr.id
#   role_definition_name = "AcrPull"
#   principal_id         = azurerm_container_app.frontend.identity[0].principal_id
# }