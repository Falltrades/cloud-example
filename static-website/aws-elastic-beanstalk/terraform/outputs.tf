output "website_url" {
  description = "Public URL of the nginx website"
  value = "http://${aws_elastic_beanstalk_environment.env.endpoint_url}"
}
