variable "name" {
  type        = string
  description = "Name of the frontend App Service"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "service_plan_id" {
  type        = string
  description = "App Service Plan ID"
}

variable "acr_login_server" {
  type        = string
  description = "ACR login server (e.g. myacr.azurecr.io)"
}

variable "acr_username" {
  type        = string
  description = "ACR admin username"
}

variable "acr_password" {
  type        = string
  description = "ACR admin password"
  sensitive   = true
}

variable "image" {
  type        = string
  description = "Full container image reference (registry/image:tag)"
}

variable "app_settings" {
  type        = map(string)
  default     = {}
  description = "Additional app settings for the frontend"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace ID for diagnostics"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the App Service"
}
