data "kubernetes_ingress_v1" "nginx_status" {
  depends_on = [kubernetes_ingress_v1.nginx]
  metadata {
    name      = kubernetes_ingress_v1.nginx.metadata[0].name
    namespace = "default"
  }
}

output "ingress_url" {
  description = "The public URL of the Nginx Ingress"
  value = "http://${data.kubernetes_ingress_v1.nginx_status.status[0].load_balancer[0].ingress[0].hostname}"
}
