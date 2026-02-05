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

## Helpful informations

Use this command to get merge the kubeconfig with `~/.kube/config`:
```shell
aws eks update-kubeconfig --name nginx-cluster --region us-east-1
```

You may need to delete `validatingwebhookconfigurations` and `mutatingwebhookconfigurations` during `terraform destroy`.
