resource "helm_release" "html-db" {
  depends_on = [module.eks_cluster]

  name          = "html-db"
  repository    = "https://falltrades.github.io/cloud-example"
  chart         = "html-db"
  namespace     = "default"
  atomic        = true
  force_update  = true
  recreate_pods = true

  values = [
    templatefile("${path.module}/files/html-db-values.yaml", {
      SUBNET_1     = module.eks_cluster.public_subnets[0]
      SUBNET_2     = module.eks_cluster.public_subnets[1]
      ALB_SG_ID    = module.eks_cluster.alb_security_group_id
      DB_NAME      = var.db_name
      DB_USER      = var.db_username
      DB_PASSWORD  = var.db_password
    })
  ]
}
