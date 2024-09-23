variable "frontend_apps" {
  description = "List of frontend applications"
  type = list(object({
    service         = string
    port         = number
    path_prefix  = string
  }))
  default = [
    {
      service     = "auth-app"
      port        = 8080
      path_prefix = "/"
    },
  ]
}

variable "api_routes" {
  description = "List of API routes with their target services"
  type = list(object({
    service     = string
    port        = number
    path_prefix = string
  }))
  default = [
    {
      service     = "auth-api"
      port        = 80
      path_prefix = "/api/auth"
    },
  ]
}

variable "service_routes" {
  description = "List of service routes with their target services"
  type = list(object({
    service     = string
    port        = number
    path_prefix = string
  }))
  default = [
    {
      service     = "auth-service"
      port        = 80
      path_prefix = "/service/auth"
    },
  ]
}
