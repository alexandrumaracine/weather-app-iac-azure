variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "container_app_environment_id" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "revision_mode" {
  type    = string
  default = "Single"
}

# ACR registry + secret setup (preserve behavior)
variable "acr_login_server" {
  type = string
}

variable "acr_admin_username" {
  type = string
}

variable "acr_admin_password" {
  type      = string
  sensitive = true
}

variable "acr_password_secret_name" {
  type    = string
  default = "acr-password"
}

# Ingress (preserve behavior)
variable "ingress_external_enabled" {
  type    = bool
  default = true
}

variable "ingress_target_port" {
  type    = number
  default = 3000
}

# Container config (preserve behavior)
variable "container_name" {
  type    = string
  default = "backend"
}

variable "image" {
  type = string
}

variable "cpu" {
  type    = number
  default = 0.5
}

variable "memory" {
  type    = string
  default = "1Gi"
}

# App env vars (preserve behavior)
variable "openweather_api_key" {
  type      = string
  sensitive = true
}

variable "mysql_host" {
  type = string
}

variable "mysql_database" {
  type = string
}

variable "mysql_user" {
  type = string
}

variable "mysql_password" {
  type      = string
  sensitive = true
}

# Scaling (preserve behavior)
variable "min_replicas" {
  type    = number
  default = 1
}

variable "max_replicas" {
  type    = number
  default = 5
}
