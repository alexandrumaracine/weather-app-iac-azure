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
        name  = "API_BASE_URL"
        value = var.api_base_url
      }

      command = var.command
    }

    min_replicas = var.min_replicas
    max_replicas = var.max_replicas
  }
}
