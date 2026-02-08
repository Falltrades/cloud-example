resource "kubernetes_service_account_v1" "alb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
    }
  }
}

resource "helm_release" "alb_controller" {
  depends_on = [
    aws_eks_cluster.nginx,
    aws_eks_fargate_profile.nginx,
    aws_eks_node_group.system_nodes,
    kubernetes_service_account_v1.alb_controller
  ]

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  values = [
    templatefile("${path.module}/files/alb-values.yaml", {
      CLUSTER_NAME         = aws_eks_cluster.nginx.name
      SERVICE_ACCOUNT_NAME = kubernetes_service_account_v1.alb_controller.metadata[0].name
      AWS_REGION           = var.aws_region
      VPC_ID               = aws_vpc.eks.id
      SUBNET_1             = aws_subnet.eks[0].id
      SUBNET_2             = aws_subnet.eks[1].id
    })
  ]
}

resource "kubernetes_ingress_v1" "nginx" {
  depends_on = [helm_release.alb_controller]

  metadata {
    name = "nginx"

    annotations = {
      "kubernetes.io/ingress.class"               = "alb"
      "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"     = "ip"
      "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTP\":80}]"
      "alb.ingress.kubernetes.io/subnets"         = join(",", aws_subnet.public[*].id)
      "alb.ingress.kubernetes.io/security-groups" = aws_security_group.alb.id
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
  depends_on = [
    aws_eks_fargate_profile.nginx
  ]

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
  depends_on = [
    aws_eks_fargate_profile.nginx
  ]

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

