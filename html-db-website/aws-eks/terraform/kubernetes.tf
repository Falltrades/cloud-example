resource "kubernetes_service_account_v1" "alb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
    }
  }
}

resource "helm_release" "alb_controller" {
  depends_on = [
    aws_eks_cluster.nginx,
    aws_eks_fargate_profile.nginx,
    aws_eks_node_group.system_nodes,
    kubernetes_service_account_v1.alb_controller
  ]

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  values = [
    templatefile("${path.module}/files/alb-values.yaml", {
      CLUSTER_NAME         = aws_eks_cluster.nginx.name
      SERVICE_ACCOUNT_NAME = kubernetes_service_account_v1.alb_controller.metadata[0].name
      AWS_REGION           = var.aws_region
      VPC_ID               = aws_vpc.eks.id
      SUBNET_1             = aws_subnet.eks[0].id
      SUBNET_2             = aws_subnet.eks[1].id
    })
  ]
}

resource "helm_release" "html-db" {
  depends_on = [helm_release.alb_controller]

  name          = "html-db"
  repository    = "https://falltrades.github.io/cloud-example"
  chart         = "html-db"
  namespace     = "default"
  atomic        = true
  force_update  = true
  recreate_pods = true

  values = [
    templatefile("${path.module}/files/html-db-values.yaml", {
      SUBNET_1     = aws_subnet.public[0].id
      SUBNET_2     = aws_subnet.public[1].id
      ALB_SG_ID    = aws_security_group.alb.id
      DB_NAME      = var.db_name
      DB_USER      = var.db_username
      DB_PASSWORD  = var.db_password
    })
  ]
}
