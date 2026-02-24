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
    aws_eks_cluster.this,
    aws_eks_fargate_profile.this,
    aws_eks_node_group.system_nodes,
    kubernetes_service_account_v1.alb_controller
  ]

  name       = "${var.cluster_name}-aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  values = [
    templatefile("${path.module}/files/alb-values.yaml", {
      CLUSTER_NAME         = aws_eks_cluster.this.name
      SERVICE_ACCOUNT_NAME = kubernetes_service_account_v1.alb_controller.metadata[0].name
      AWS_REGION           = var.aws_region
      VPC_ID               = aws_vpc.eks.id
      SUBNET_1             = aws_subnet.eks[0].id
      SUBNET_2             = aws_subnet.eks[1].id
    })
  ]
}
