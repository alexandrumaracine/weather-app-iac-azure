resource "azurerm_linux_web_app" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.service_plan_id

  site_config {
    always_on = true

    application_stack {
      docker_image_name        = var.image
      docker_registry_url      = "https://${var.acr_login_server}"
      docker_registry_username = var.acr_username
      docker_registry_password = var.acr_password
    }
  }

  app_settings = merge(
    {
      WEBSITES_PORT = "8080"
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
