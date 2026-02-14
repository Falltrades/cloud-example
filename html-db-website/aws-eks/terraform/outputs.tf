# Wait for the Ingress to be created by Helm, then read its status
data "kubernetes_ingress_v1" "html_db_ingress" {
  depends_on = [helm_release.html-db]
  metadata {
    name      = "html-db-ingress" # Must match the name in your Helm templates/ingress.yaml
    namespace = "default"
  }
}

output "ingress_url" {
  description = "The public URL of the ALB"
  value       = "http://${data.kubernetes_ingress_v1.html_db_ingress.status[0].load_balancer[0].ingress[0].hostname}"
}
