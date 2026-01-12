variable "project_name" {
  description = "Project name used for naming MySQL server"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "admin_username" {
  description = "MySQL administrator username"
  type        = string
}

variable "admin_password" {
  description = "MySQL administrator password"
  type        = string
  sensitive   = true
}

variable "database_name" {
  description = "MySQL database name"
  type        = string
}

variable "tags" {
  description = "Tags applied to MySQL resources"
  type        = map(string)
}
