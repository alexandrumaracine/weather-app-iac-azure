variable "name" {
  description = "Log Analytics workspace name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "sku" {
  description = "Log Analytics SKU"
  type        = string
}

variable "retention_in_days" {
  description = "Retention period in days"
  type        = number
}

variable "tags" {
  description = "Tags applied to the workspace"
  type        = map(string)
  default     = {}
}
