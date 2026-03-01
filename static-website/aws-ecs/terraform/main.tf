module "web" {
  source          = "../../../terraform-modules/aws/ecs-app"
  project         = "nginx"
  container_image = "ghcr.io/falltrades/cloud-example/html:1.0.0"
}
