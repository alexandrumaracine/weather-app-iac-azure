variable "name" {
  type        = string
  description = "Name of the autoscale setting"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "target_resource_id" {
  type        = string
  description = "Resource ID of the App Service Plan"
}

variable "min_capacity" {
  type        = number
  description = "Minimum number of instances"
  default     = 1
}

variable "default_capacity" {
  type        = number
  description = "Default number of instances"
  default     = 1
}

variable "max_capacity" {
  type        = number
  description = "Maximum number of instances"
  default     = 5
}

variable "cpu_scale_out_threshold" {
  type        = number
  description = "CPU percentage to trigger scale out"
  default     = 70
}

variable "cpu_scale_in_threshold" {
  type        = number
  description = "CPU percentage to trigger scale in"
  default     = 30
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags for autoscale resource"
}
