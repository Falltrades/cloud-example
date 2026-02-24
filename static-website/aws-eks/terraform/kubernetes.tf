resource "kubernetes_ingress_v1" "nginx" {
  depends_on = [module.eks_cluster] 

  metadata {
    name = "nginx"

    annotations = {
      "kubernetes.io/ingress.class"               = "alb"
      "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"     = "ip"
      "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTP\":80}]"
      "alb.ingress.kubernetes.io/subnets"         = join(",", module.eks_cluster.public_subnets)
      "alb.ingress.kubernetes.io/security-groups" = module.eks_cluster.alb_security_group_id
    }
  }

  spec {
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service_v1.nginx.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment_v1" "nginx" {
  depends_on = [module.eks_cluster]

  metadata {
    name = "nginx"
    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "ghcr.io/falltrades/cloud-example/html:1.0.0"

          port {
            container_port = 8080
          }

          resources {
            requests = {
              cpu    = "50m"
              memory = "128Mi"
            }

            limits = {
              cpu    = "250m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "nginx" {
  depends_on = [module.eks_cluster]

  metadata {
    name = "nginx"
  }

  spec {
    type = "ClusterIP"

    selector = {
      app = kubernetes_deployment_v1.nginx.metadata[0].labels.app
    }

    port {
      port        = 80
      target_port = 8080
    }
  }
}
