module "web" {
  source          = "../../../../terraform-modules/aws/ecs-app"
  project         = "event-driven"
  container_image = "ghcr.io/falltrades/cloud-example/event-driven-frontend:1.0.0"
  app_port        = 80
  
  container_environment = [
    { name = "api_url", value = "ws://${module.web.website_dns}/ws" }
  ]

  sidecar_containers = {
    ws-server = {
      image  = "ghcr.io/falltrades/cloud-example/event-driven-monolith-backend:1.0.0"
      cpu    = 256
      memory = 512
      portMappings = [{
        containerPort = 3001
        protocol      = "tcp"
      }]
      readonlyRootFilesystem = false
    }
  }
}
