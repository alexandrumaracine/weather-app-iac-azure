resource "azurerm_linux_web_app" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.service_plan_id

  site_config {
    always_on         = true
  }

  app_settings = merge(
    {
      WEBSITES_PORT                   = "80"
      DOCKER_REGISTRY_SERVER_URL      = "https://${var.acr_login_server}"
      DOCKER_REGISTRY_SERVER_USERNAME = var.acr_username
      DOCKER_REGISTRY_SERVER_PASSWORD = var.acr_password

      DOCKER_CUSTOM_IMAGE_NAME = var.image
    },
    var.app_settings
  )

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  name                       = "${var.name}-logs"
  target_resource_id         = azurerm_linux_web_app.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AppServiceConsoleLogs"
  }

  metric {
    category = "AllMetrics"
  }
}
