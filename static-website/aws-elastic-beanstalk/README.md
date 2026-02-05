# AWS-Elastic-Beanstalk

This is an example repository containing Terraform code. It contains the code to deploy a static web page using AWS Elastic Beanstalk.  

## Tree
```
.
├── misc
│   └── architecture.dot.png   # Generated with https://github.com/patrickchugh/terravision
├── README.md
└── terraform
    ├── files
    │   ├── Dockerrun.aws.json
    │   └── Dockerrun.zip
    ├── iam.tf
    ├── main.tf
    ├── outputs.tf
    ├── provider.tf
    └── variables.tf
```

## Architecture diagram

<img src="./misc/architecture.dot.png">

## Infracost

```shell
 Name                                                          Monthly Qty  Unit                    Monthly Cost

 aws_elastic_beanstalk_environment.env
 ├─ aws_launch_configuration
 │  ├─ Instance usage (Linux/UNIX, on-demand, t3.micro)                730  hours                          $7.59
 │  └─ aws_ebs_volume
 │     └─ Storage (general purpose SSD, gp2)                             8  GB                             $0.80
 └─ aws_loadbalancer
    ├─ Network load balancer                                           730  hours                         $16.43
    └─ Load balancer capacity units                      Monthly cost depends on usage: $4.38 per LCU

 aws_s3_bucket.app_bucket
 └─ Standard
    ├─ Storage                                           Monthly cost depends on usage: $0.023 per GB
    ├─ PUT, COPY, POST, LIST requests                    Monthly cost depends on usage: $0.005 per 1k requests
    ├─ GET, SELECT, and all other requests               Monthly cost depends on usage: $0.0004 per 1k requests
    ├─ Select data scanned                               Monthly cost depends on usage: $0.002 per GB
    └─ Select data returned                              Monthly cost depends on usage: $0.0007 per GB

 OVERALL TOTAL                                                                                           $24.82

*Usage costs can be estimated by updating Infracost Cloud settings, see docs for other options.

──────────────────────────────────
9 cloud resources were detected:
∙ 2 were estimated
∙ 6 were free
∙ 1 is not supported yet, see https://infracost.io/requested-resources:
  ∙ 1 x aws_elastic_beanstalk_application_version

┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━┳━━━━━━━━━━━━┓
┃ Project                                            ┃ Baseline cost ┃ Usage cost* ┃ Total cost ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━╋━━━━━━━━━━━━┫
┃ terraform                                          ┃           $25 ┃           - ┃        $25 ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━┻━━━━━━━━━━━━┛
```

## Helpful informations
