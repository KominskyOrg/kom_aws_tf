locals {
  api_ingress_paths = flatten([
    for env in var.environments : [
      for api in var.api_routes : {
        path         = "${api.path_prefix}"
        pathType     = "Prefix"
        service_name = api.service
        service_port = api.port
      }
    ]
  ])

  service_ingress_paths = flatten([
    for env in var.environments : [
      for svc in var.service_routes : {
        path         = "${svc.path_prefix}"
        pathType     = "Prefix"
        service_name = svc.service
        service_port = svc.port
      }
    ]
  ])

  frontend_ingress_paths = flatten([
    for env in var.environments : [
      for frontend in var.frontend_apps : {
        path         = "/${frontend.path_prefix}/"
        pathType     = "Prefix"
        service_name = frontend.service_name
        service_port = frontend.port
      }
    ]
  ])

  all_ingress_paths = concat(
    local.api_ingress_paths,
    local.service_ingress_paths,
    local.frontend_ingress_paths,
    [
      for env in var.environments : {
        path         = "/*"
        pathType     = "Prefix"
        service_name = var.frontend_apps[0].service_name
        service_port = var.frontend_apps[0].port
      }
    ]
  )
}

resource "kubernetes_ingress_v1" "app_ingress" {
  metadata {
    name      = "app-ingress"
    namespace = kubernetes_namespace.environment[var.env].metadata[0].name

    annotations = {
      "kubernetes.io/ingress.class"                = "alb"
      "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
      "alb.ingress.kubernetes.io/ssl-redirect"     = "443"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/health"
      "alb.ingress.kubernetes.io/listen-ports"     = jsonencode([
        { HTTP = 80 },
        { HTTPS = 443 }
      ])
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      host = "jaredkominsky.com"

      http {
        dynamic "path" {
          for_each = local.all_ingress_paths

          content {
            path     = path.value.path
            path_type = path.value.pathType

            backend {
              service {
                name = path.value.service_name
                port {
                  number = path.value.service_port
                }
              }
            }
          }
        }
      }
    }
  }
}