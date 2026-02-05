# AWS-EKS 

This is an example repository containing Terraform. It contains the code to deploy a static web page using EKS with an EC2 node pool for `kube-system` deployment (coredns, aws-load-balancer-controller) and a Fargate pool for the nginx deployment.  

## Tree
```
.
├── misc
│   └── architecture.dot.png   # Generated with https://github.com/patrickchugh/terravision.
├── README.md
└── terraform
    ├── files
    │   ├── alb-policy.json
    │   └── alb-values.yaml
    ├── iam.tf
    ├── kubernetes.tf          # We are deploying Kubernetes object here.
    ├── main.tf
    ├── network.tf
    ├── outputs.tf
    ├── provider.tf
    ├── security_group.tf
    └── variables.tf
```

## Architecture diagram

<img src="./misc/architecture.dot.png">

## Infracost

```shell
 Name                                                     Monthly Qty  Unit              Monthly Cost

 aws_eks_cluster.nginx
 └─ EKS cluster                                                   730  hours                   $73.00

 aws_nat_gateway.eks
 ├─ NAT gateway                                                   730  hours                   $32.85
 └─ Data processed                                     Monthly cost depends on usage: $0.045 per GB

 aws_eks_fargate_profile.nginx
 ├─ Per GB per hour                                                 1  GB                       $3.24
 └─ Per vCPU per hour                                               1  CPU                     $29.55

 aws_eks_node_group.system_nodes
 ├─ Instance usage (Linux/UNIX, on-demand, t3.medium)             730  hours                   $30.37
 └─ Storage (general purpose SSD, gp2)                             20  GB                       $2.00

 OVERALL TOTAL                                                                               $171.01

*Usage costs can be estimated by updating Infracost Cloud settings, see docs for other options.

──────────────────────────────────
31 cloud resources were detected:
∙ 4 were estimated
∙ 27 were free

┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━┳━━━━━━━━━━━━┓
┃ Project                                            ┃ Baseline cost ┃ Usage cost* ┃ Total cost ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━╋━━━━━━━━━━━━┫
┃ terraform                                          ┃          $171 ┃           - ┃       $171 ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━┻━━━━━━━━━━━━┛
```

## Helpful informations

Use this command to get merge the kubeconfig with `~/.kube/config`:
```shell
aws eks update-kubeconfig --name nginx-cluster --region us-east-1
```

You may need to delete `validatingwebhookconfigurations` and `mutatingwebhookconfigurations` during `terraform destroy`.
