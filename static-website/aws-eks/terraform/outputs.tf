output "ingress_url" {
  description = "The public URL of the Nginx Ingress"
  value       = "http://${kubernetes_ingress_v1.nginx.status[0].load_balancer[0].ingress[0].hostname}"
}
