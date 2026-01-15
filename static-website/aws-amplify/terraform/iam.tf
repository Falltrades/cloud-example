resource "aws_iam_role" "amplify_build_role" {
  name = "amplify-build-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = [
            "amplify.${var.aws_region}.amazonaws.com",
            "amplify.amazonaws.com"
          ]
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "amplify_policy_attach" {
  role       = aws_iam_role.amplify_build_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess-Amplify"
}
