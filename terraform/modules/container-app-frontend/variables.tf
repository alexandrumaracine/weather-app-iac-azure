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

# ACR
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

# Ingress
variable "ingress_external_enabled" {
  type    = bool
  default = true
}

variable "ingress_target_port" {
  type    = number
  default = 3000
}

# Container
variable "container_name" {
  type    = string
  default = "frontend"
}

variable "image" {
  type = string
}

variable "cpu" {
  type    = number
  default = 0.25
}

variable "memory" {
  type    = string
  default = "0.5Gi"
}

# Runtime config
variable "api_base_url" {
  type = string
}

variable "command" {
  type = list(string)
}

# Scaling
variable "min_replicas" {
  type    = number
  default = 1
}

variable "max_replicas" {
  type    = number
  default = 3
}
