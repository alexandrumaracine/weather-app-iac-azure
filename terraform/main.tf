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

module "app_service_plan" {
  count = var.enable_app_service ? 1 : 0

  source              = "./modules/app-service-plan"
  name                = "${var.project_name}-asp"
  resource_group_name = module.rg.name
  location            = module.rg.location
  sku_name            = var.app_service_plan_sku
  tags                = local.tags
}

module "app_service_backend" {
  count = var.enable_app_service ? 1 : 0
  source = "./modules/app-service-backend"

  name                = "${var.project_name}-backend-as"
  resource_group_name = module.rg.name
  location            = module.rg.location
  service_plan_id     = module.app_service_plan[0].id

  log_analytics_workspace_id = module.log_analytics.id
  tags = local.tags

  acr_login_server = module.acr.login_server
  acr_username     = module.acr.admin_username
  acr_password     = module.acr.admin_password

  image_tag = var.app_service_backend_image_tag

  app_settings = {
    OPENWEATHER_API_KEY = var.openweather_api_key

    MYSQL_HOST = module.mysql.fqdn
    MYSQL_DB   = var.mysql_database

    # ✅ APP USER (NOT ADMIN)
    MYSQL_USER = "weatherapp"
    MYSQL_PASS = var.mysql_app_password

    # ✅ SSL MUST BE ENABLED
    MYSQL_SSL_DISABLED = "false"

    WEBSITES_PORT = "3000"
  }
}



module "app_service_frontend" {
  count = var.enable_app_service ? 1 : 0
  source = "./modules/app-service-frontend"

  name                = "${var.project_name}-frontend-as"
  resource_group_name = module.rg.name
  location            = module.rg.location
  service_plan_id     = module.app_service_plan[0].id

  log_analytics_workspace_id = module.log_analytics.id

  tags = local.tags

  acr_login_server = module.acr.login_server
  acr_username     = module.acr.admin_username
  acr_password     = module.acr.admin_password

  image_tag = var.app_service_frontend_image_tag

  app_settings = {
    BACKEND_URL = module.app_service_backend[0].url
  }
}


module "app_service_autoscale" {
  count = var.enable_app_service ? 1 : 0

  source              = "./modules/monitor-autoscale"
  name                = "${var.project_name}-asp-autoscale"
  resource_group_name = module.rg.name
  location            = module.rg.location
  target_resource_id  = module.app_service_plan[0].id

  min_capacity      = 1
  default_capacity  = 1
  max_capacity      = 5

  cpu_scale_out_threshold = 70
  cpu_scale_in_threshold  = 30

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

  mysql_host     = module.mysql.server_name
  mysql_database = var.mysql_database
  mysql_user     = "${var.mysql_admin_user}@${module.mysql.server_name}"
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