output "amplify_website_url" {
  description = "Public URL of the Amplify-hosted website"
  value       = "https://${aws_amplify_branch.main.branch_name}.${aws_amplify_app.static_site.default_domain}"
}

