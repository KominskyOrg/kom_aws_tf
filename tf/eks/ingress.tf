locals {
  api_ingress_paths = flatten([
    for api in var.api_routes : {
      path         = "${api.path_prefix}"
      pathType     = "Prefix"
      service_name = api.service
      service_port = api.port
    }
    ]
  )

  frontend_ingress_paths = flatten([
    for frontend in var.frontend_apps : {
      path         = "${frontend.path_prefix}"
      pathType     = "Prefix"
      service_name = frontend.service
      service_port = frontend.port
    }
    ]
  )

  all_ingress_paths = concat(
    local.api_ingress_paths, 
    local.frontend_ingress_paths
  )
}

resource "kubernetes_service" "ssl_redirect" {
  metadata {
    name      = "ssl-redirect"
    namespace = kubernetes_namespace.environment.metadata[0].name
  }

  spec {
    type = "ClusterIP"

    port {
      name        = "use-annotation"
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_ingress_v1" "app_ingress" {
  metadata {
    name      = "${var.env}-ingress"
    namespace = kubernetes_namespace.environment.metadata[0].name

    annotations = {
      "alb.ingress.kubernetes.io/target-type"      = "ip"
      "kubernetes.io/ingress.class"                = "alb"
      "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/health"
      "alb.ingress.kubernetes.io/listen-ports" = jsonencode([
        { HTTP = 80 },
        { HTTPS = 443 }
      ])
      "alb.ingress.kubernetes.io/certificate-arn"  = var.certificate_arn
      "alb.ingress.kubernetes.io/backend-protocol" = "HTTP"

      # Redirect HTTP to HTTPS
      "alb.ingress.kubernetes.io/actions.ssl-redirect" = jsonencode({
        Type = "redirect"
        RedirectConfig = {
          Protocol   = "HTTPS"
          Port       = "443"
          StatusCode = "HTTP_301"
        }
      })

    }
  }

  spec {
    ingress_class_name = "alb"

    # Default Rule: Redirect HTTP to HTTPS
    rule {
      http {
        path {
          path      = "/*"
          path_type = "ImplementationSpecific"

          backend {
            service {
              name = kubernetes_service.ssl_redirect.metadata[0].name
              port {
                name = kubernetes_service.ssl_redirect.spec[0].port[0].name
              }
            }
          }
        }
      }
    }


    # Host-Specific Rule: Route Traffic to auth-app
    rule {
      host = "${var.env}.jaredkominsky.com"

      http {
        dynamic "path" {
          for_each = local.all_ingress_paths

          content {
            path      = path.value.path
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

