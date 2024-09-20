variable "environments" {
  description = "List of environments (e.g., dev, prod)"
  type        = list(string)
  default     = ["dev"]
}

variable "frontend_apps" {
  description = "List of frontend applications"
  type = list(object({
    name = string
    service_name = string
    port = number
    path_prefix = string
  }))
  default = [
    {
      name         = "auth_app"
      service_name = "auth-app"
      port         = 3000
      path_prefix  = "auth"
    },
  ]
}

variable "api_routes" {
  description = "List of API routes with their target services"
  type = list(object({
    path_prefix = string
    service     = string
    port        = number
  }))
  default = [
    {
      path_prefix = "/api/auth/*"
      service     = "auth-api"
      port        = 5000
    },
  ]
}

variable "service_routes" {
  description = "List of service routes with their target services"
  type = list(object({
    path_prefix = string
    service     = string
    port        = number
  }))
  default = [
    {
      path_prefix = "/service/auth/*"
      service     = "auth-service"
      port        = 5001
    },
  ]
}