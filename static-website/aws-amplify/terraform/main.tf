resource "aws_amplify_app" "static_site" {
  name                 = "hello-static-site"
  repository           = "https://github.com/Falltrades/cloud-example"
  access_token         = var.personal_access_token
  iam_service_role_arn = aws_iam_role.amplify_build_role.arn

  # Required even for static sites
  build_spec = <<EOF
version: 1
applications:
  - appRoot: static-website/aws-amplify/website
    frontend:
      phases:
        build:
          commands: []
      artifacts:
        baseDirectory: .
        files:
          - '**/*'
      cache:
        paths: []
EOF

  environment_variables = {
    AMPLIFY_MONOREPO_APP_ROOT = "static-website/aws-amplify/website"
  }
}

resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.static_site.id
  branch_name = "main"

  enable_auto_build = true
}
