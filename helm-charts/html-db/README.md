# html-db

![Version: 1.0.1](https://img.shields.io/badge/Version-1.0.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

This Helm chart deploy a basic html application using a relational database as backend.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| falltrades |  | <https://falltrades.github.io/engineering> |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| db | object | `{"name":"myapp","password":"password","user":"admin"}` | Database connection and credential settings |
| db.name | string | `"myapp"` | Name of the database to create |
| db.password | string | `"password"` | Password for the database |
| db.user | string | `"admin"` | Username for the database administrator |
| image | object | `{"db":"postgres:15","web":"ghcr.io/falltrades/cloud-example/html-db:1.0.0"}` | Image configuration for the application components |
| image.db | string | `"postgres:15"` | The image for the postgres database |
| image.web | string | `"ghcr.io/falltrades/cloud-example/html-db:1.0.0"` | The image for the web application |
| ingress | object | `{"annotations":{"cert-manager.io/cluster-issuer":"letsencrypt-prod","kubernetes.io/ingress.class":"nginx"},"className":"nginx","enabled":true,"host":"html-db.example.com","tls":{"enabled":true,"secretName":"html-db-tls"}}` | Ingress configuration to expose the web service |
| ingress.annotations | object | `{"cert-manager.io/cluster-issuer":"letsencrypt-prod","kubernetes.io/ingress.class":"nginx"}` | Annotations for the Ingress (e.g., for cert-manager) |
| ingress.className | string | `"nginx"` | Ingress class name (usually 'nginx') |
| ingress.enabled | bool | `true` | Enable ingress record generation |
| ingress.host | string | `"html-db.example.com"` | Hostname for the application |
| ingress.tls | object | `{"enabled":true,"secretName":"html-db-tls"}` | TLS configuration |
| service | object | `{"dbPort":5432,"webPort":8080}` | Port configurations for internal services |
| service.dbPort | int | `5432` | The port the database container listens on |
| service.webPort | int | `8080` | The port the web container listens on |

