output "website_url" {
  description = "Public URL of the nginx website via ALB"
  value       = "http://${module.web.alb_dns_name}"
}
