variable "project" {
  type    = string
  default = "weather-app"
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "tags" {
  type = map(string)
  default = {
    project = "weather-app"
    env     = "hackathon"
  }
}

# DB (hackathon-safe values go in tfvars, not here)
variable "db_name" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)

  default = {
    Owner   = "AlexMara"
    Project = "WeatherApp"
    Env     = "Hackathon"
    Managed = "Terraform"
  }
}