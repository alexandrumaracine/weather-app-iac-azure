variable "location" {
  default = "westeurope"
}

variable "project_name" {
  default = "skycastnow"
}

variable "owner" {
  default = "AlexMara"
}

variable "openweather_api_key" {
  sensitive = true
}

variable "mysql_admin_user" {
  default = "weatheruser"
}

variable "mysql_admin_password" {
  sensitive = true
}

variable "mysql_database" {
  default = "weatherdb"
}

variable "backend_name" {
  type        = string
  default     = "skycastnow-backend"
  description = "Azure Container App name for backend"
}

variable "frontend_name" {
  type        = string
  default     = "skycastnow-frontend"
  description = "Azure Container App name for frontend"
}

variable "backend_image" {
  type        = string
  description = "Full backend image reference in ACR (e.g. myacr.azurecr.io/backend:1.0.1)"
}

variable "frontend_image" {
  type        = string
  description = "Full frontend image reference in ACR (e.g. myacr.azurecr.io/frontend:1.0.1)"
}

variable "deploy_apps" {
  description = "When false, do NOT create the frontend/backend Container Apps (infra only)."
  type        = bool
  default     = false
}