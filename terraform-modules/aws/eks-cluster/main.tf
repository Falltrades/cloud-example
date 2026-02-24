resource "aws_eks_cluster" "this" {
  depends_on = [aws_iam_role_policy_attachment.eks_cluster]

  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids              = aws_subnet.eks[*].id
    endpoint_public_access  = true
    endpoint_private_access = false
  }
}

resource "aws_eks_fargate_profile" "this" {
  depends_on = [aws_eks_cluster.this]

  cluster_name           = aws_eks_cluster.this.name
  fargate_profile_name   = "this-fargate"
  pod_execution_role_arn = aws_iam_role.fargate.arn
  subnet_ids             = aws_subnet.eks[*].id

  selector {
    namespace = "default"

    labels = {
      app = "${var.cluster_name}"
    }
  }
}

resource "aws_eks_node_group" "system_nodes" {
  depends_on = [aws_eks_cluster.this]

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "system-nodes"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = aws_subnet.eks[*].id

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  instance_types = ["t3.medium"]
}

