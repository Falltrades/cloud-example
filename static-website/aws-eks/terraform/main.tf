module "eks_cluster" {
  source       = "../../../terraform-modules/aws/eks-cluster"
  cluster_name = "nginx"
}
