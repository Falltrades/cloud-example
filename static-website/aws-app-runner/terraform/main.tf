resource "aws_apprunner_service" "nginx" {
  service_name = "nginx"

  source_configuration {
    authentication_configuration {
      connection_arn = aws_apprunner_connection.github.arn
    }

    code_repository {
      repository_url = "https://github.com/Falltrades/cloud-example"

      source_code_version {
        type  = "BRANCH"
        value = "main"
      }

      source_directory = "static-website/aws-app-runner/app"

      code_configuration {
        configuration_source = "REPOSITORY"
      }
    }

    auto_deployments_enabled = true
  }
}

resource "aws_apprunner_connection" "github" {
  connection_name = "github-connection"
  provider_type   = "GITHUB"
}
