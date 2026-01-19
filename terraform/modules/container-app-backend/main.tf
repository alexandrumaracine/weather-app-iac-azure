resource "azurerm_container_app" "this" {
  name                         = var.name
  resource_group_name          = var.resource_group_name
  container_app_environment_id = var.container_app_environment_id
  revision_mode                = var.revision_mode
  tags                         = var.tags

  lifecycle {
    ignore_changes = [
      registry,
      secret
    ]
  }

  secret {
    name  = var.acr_password_secret_name
    value = var.acr_admin_password
  }

  registry {
    server               = var.acr_login_server
    username             = var.acr_admin_username
    password_secret_name = var.acr_password_secret_name
  }

  ingress {
    external_enabled = var.ingress_external_enabled
    target_port      = var.ingress_target_port

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    container {
      name   = var.container_name
      image  = var.image
      cpu    = var.cpu
      memory = var.memory

      env {
        name  = "OPENWEATHER_API_KEY"
        value = var.openweather_api_key
      }

      env {
        name  = "MYSQL_HOST"
        value = var.mysql_host
      }

      env {
        name  = "MYSQL_DATABASE"
        value = var.mysql_database
      }

      env {
        name  = "MYSQL_USER"
        value = var.mysql_user
      }

      env {
        name  = "MYSQL_PASSWORD"
        value = var.mysql_password
      }
    }

    min_replicas = var.min_replicas
    max_replicas = var.max_replicas
  }
}
