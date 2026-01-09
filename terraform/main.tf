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

resource "azurerm_container_registry" "acr" {
  name                = "${var.project_name}acr"
  resource_group_name = module.rg.name
  location            = module.rg.location
  sku                 = "Basic"
  admin_enabled       = true
  tags                = local.tags
}

resource "azurerm_log_analytics_workspace" "logs" {
  name                = "${var.project_name}-logs"
  resource_group_name = module.rg.name
  location            = module.rg.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}

resource "azurerm_container_app_environment" "env" {
  name                       = "${var.project_name}-env"
  location                   = module.rg.location
  resource_group_name        = module.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id
  tags                       = local.tags
}

resource "azurerm_mysql_flexible_server" "mysql" {
  name                = "${var.project_name}-mysql"
  resource_group_name = module.rg.name
  location            = module.rg.location

  administrator_login    = var.mysql_admin_user
  administrator_password = var.mysql_admin_password

  sku_name = "GP_Standard_D2ds_v4"     //"B_Standard_B1ms"
  # version  = "8.0.21"

  storage {
    size_gb = 20
  }

  backup_retention_days = 7
  tags                  = local.tags
}

resource "azurerm_mysql_flexible_database" "db" {
  name                = var.mysql_database
  resource_group_name = module.rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}


resource "azurerm_mysql_flexible_server_firewall_rule" "allow_azure" {
  name                = "allow-azure"
  resource_group_name = module.rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}



# ----------------------------
# Container Apps: Backend
# ----------------------------
resource "azurerm_container_app" "backend" {
  count = var.deploy_apps ? 1 : 0

  name                         = var.backend_name
  resource_group_name          = module.rg.name
  container_app_environment_id = azurerm_container_app_environment.env.id
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
    value = azurerm_container_registry.acr.admin_password
  }

  registry {
    server               = azurerm_container_registry.acr.login_server
    username             = azurerm_container_registry.acr.admin_username
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
        value = azurerm_mysql_flexible_server.mysql.fqdn
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
  container_app_environment_id = azurerm_container_app_environment.env.id
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
    value = azurerm_container_registry.acr.admin_password
  }

  registry {
    server               = azurerm_container_registry.acr.login_server
    username             = azurerm_container_registry.acr.admin_username
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