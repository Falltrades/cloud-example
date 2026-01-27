resource "aws_lightsail_container_service" "nginx_container_service" {
  name  = var.service_name
  power = "nano"
  scale = 1
}

resource "aws_lightsail_container_service_deployment_version" "nginx_deployment" {
  service_name = aws_lightsail_container_service.nginx_container_service.name

  container {
    container_name = "nginx"
    image          = var.container_image

    ports = {
      8080 = "HTTP"
    }
  }

  public_endpoint {
    container_name = "nginx"
    container_port = 8080

    health_check {
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout_seconds     = 2
      interval_seconds    = 5
      path                = "/"
      success_codes       = "200"
    }
  }
}
