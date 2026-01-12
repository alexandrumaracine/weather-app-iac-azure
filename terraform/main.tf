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
resource "azurerm_container_app" "backend" {
  count = var.deploy_apps ? 1 : 0

  name                         = var.backend_name
  resource_group_name          = module.rg.name
  container_app_environment_id = module.container_app_env.id
  revision_mode                = "Single"
  tags                         = local.tags


  lifecycle {
  ignore_changes = [
    registry,
    secret
  ]
}

  secret {
    name  = "acr-password"
    value = module.acr.admin_password
  }

  registry {
    server               = module.acr.login_server
    username             = module.acr.admin_username
    password_secret_name = "acr-password"
  }

  ingress {
    external_enabled = true
    target_port      = 3000

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    container {
      name   = "backend"
      image = var.backend_image
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "OPENWEATHER_API_KEY"
        value = var.openweather_api_key
      }

      env {
        name  = "MYSQL_HOST"
        value = module.mysql.fqdn
      }

      env {
        name  = "MYSQL_DATABASE"
        value = var.mysql_database
      }

      env {
  name  = "MYSQL_USER"
  value = var.mysql_admin_user
}

      env {
        name  = "MYSQL_PASSWORD"
        value = var.mysql_admin_password
      }
    }

    min_replicas = 1
    max_replicas = 5

  }
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
resource "azurerm_container_app" "frontend" {
  count = var.deploy_apps ? 1 : 0

  name                         = var.frontend_name
  resource_group_name          = module.rg.name
  container_app_environment_id = module.container_app_env.id
  revision_mode                = "Single"
  tags                         = local.tags

  lifecycle {
  ignore_changes = [
    registry,
    secret
  ]
}

  secret {
    name  = "acr-password"
    value = module.acr.admin_password
  }

  registry {
    server               = module.acr.login_server
    username             = module.acr.admin_username
    password_secret_name = "acr-password"
  }

  ingress {
    external_enabled = true
    target_port      = 3000

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    container {
      name   = "frontend"
      image = var.frontend_image
      cpu    = 0.25
      memory = "0.5Gi"

      env {
  name  = "API_BASE_URL"
  value = var.deploy_apps ? "https://${azurerm_container_app.backend[0].ingress[0].fqdn}" : ""
}


      command = [
    "sh",
    "-c",
    "echo \"window.RUNTIME_CONFIG={API_BASE_URL:'$API_BASE_URL'};\" > /app/frontend/build/runtime-config.js && serve -s build -l 3000"
  ]
    }

    min_replicas = 1
    max_replicas = 3
  }
}
# Allow frontend container app identity to pull from ACR
# resource "azurerm_role_assignment" "frontend_acr_pull" {
#   scope                = azurerm_container_registry.acr.id
#   role_definition_name = "AcrPull"
#   principal_id         = azurerm_container_app.frontend.identity[0].principal_id
# }