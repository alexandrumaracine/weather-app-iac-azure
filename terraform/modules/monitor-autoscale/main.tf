resource "azurerm_monitor_autoscale_setting" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = var.target_resource_id
  enabled             = true

  profile {
    name = "cpu-autoscale-profile"

    capacity {
      minimum = tostring(var.min_capacity)
      default = tostring(var.default_capacity)
      maximum = tostring(var.max_capacity)
    }

    # -------------------------
    # Scale OUT rule
    # -------------------------
    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = var.target_resource_id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = var.cpu_scale_out_threshold
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    # -------------------------
    # Scale IN rule
    # -------------------------
    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = var.target_resource_id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT10M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = var.cpu_scale_in_threshold
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT10M"
      }
    }
  }

  tags = var.tags
}
