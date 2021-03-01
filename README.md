![](https://img.shields.io/badge/status-In%20development-yellow)
![](https://img.shields.io/badge/license-Apache%202.0-blue)
![Release Helm chart](https://github.com/vertigobr/vkpr/workflows/Release%20Helm%20chart/badge.svg)
# VKPR - Vertigo Kubernetes Production Runtime

VKPR is inspired in the [BKPR project](https://github.com/bitnami/kube-prod-runtime) but it's handed over through Helm chart.

[&#x1f1fa;&#x1f1f8; &#x1f1ec;&#x1f1e7; English](README.md) | [&#x1f1e7;&#x1f1f7; &#x1f1f5;&#x1f1f9; Português](README_pt.md)

## Description

VKPR was developed to make Kubernetes easier to use. It is composed of third-party sets, organized to deliver a production-ready Kubernetes with minimal effort.

The project is structured in stacks that group products with correlated objective. At the moment, these are the available stacks:

- **[Ingress stack](#ingress-stack):**
  - NGINX Ingress Controller
  - ExternalDNS
- **[Logging stack](#logging-stack):**
  - Loki
- **[Monitoring stack](#monitoring-stack):**
  - Prometheus Operator
    - Grafana
    - Prometheus
    - Alertmanager
- **[Security stack](#security-stack):**
  - cert-manager
  - Vault
  - Keycloak
- **[Backup stack](#backup-stack):**
  - Velero

## Installation

The VKPR installation uses [helm](https://helm.sh/):

```sh
helm repo add vertigo https://charts.vertigo.com.br
helm repo update
helm upgrade -i -f values.yaml -n vkpr vkpr vertigo/vkpr
```

Take a look on [VKPR documentation](https://vertigobr.github.io/vkpr-docs/docs/) to check the installation for a more specific scenario.

## Stack

### Ingress stack
  
The **Ingress stack** is dedicated to tools that configure external connections to Kubernetes.

- [NGINX Ingress Controller](https://vertigobr.github.io/vkpr-docs/docs/stacks#nginx-ingress-controller) is a Kubernetes Ingress Controller using NGINX as a reverse proxy and load balancer.
- [ExternalDNS](https://vertigobr.github.io/vkpr-docs/docs/stacks#externaldns) is a Kubernetes addon that configures public DNS servers with information about services exposed by Kubernetes and making them discoverable.

### Logging stack

The **Logging Stack** is dedicated to distributed logs management tools.

- [Loki](https://vertigobr.github.io/vkpr-docs/docs/stacks#loki) is a horizontally-scalable, highly-available, multi-tenant log aggregation system inspired by Prometheus.

### Monitoring stack

The **Monitoring Stack** is dedicated to observation and metrics management tools either for your services, applications or the Kubernetes Cluster.

- [Prometheus Operator](https://vertigobr.github.io/vkpr-docs/docs/stacks#prometheus-stack) provides Kubernetes native deployment and management of Prometheus and related monitoring components. Prometheus Operator contains the following modules:
  - [Grafana](https://grafana.com/oss/grafana/) allows you to query, visualize and alert on metrics and logs no matter where they are stored.
  - [Prometheus](https://grafana.com/oss/prometheus/) monitoring system includes a rich, multidimensional data model, a concise and powerful query language called PromQL, an efficient embedded timeseries database, and over 150 integrations with third-party systems.
  - [Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/) handles alerts sent by client applications such as the Prometheus server.

### Security stack

The **Security Stack** is dedicated to security tools, like identity and secret management, to your services.

- [cert-manager](https://vertigobr.github.io/vkpr-docs/docs/stacks#cert-manager) is a Kubernetes addon to automate the management and issuance of TLS certificates from various issuing sources.
- [Vault](https://vertigobr.github.io/vkpr-docs/docs/stacks#vault) secures, stores, and tightly controls access to tokens, passwords, certificates, API keys, and other secrets in modern computing. 
- [Keycloak](https://vertigobr.github.io/vkpr-docs/docs/stacks#keycloak) is an Open Source Identity and Access Management solution for modern Applications and Services.

### Backup stack

The **Backup Stack** is dedicated to backup and restore tools in order to migrate Kubernetes cluster's resources and persistent volumes.

- [Velero](https://vertigobr.github.io/vkpr-docs/docs/stacks#velero) is an open source tool to safely backup and restore, perform disaster recovery, and migrate Kubernetes cluster resources and persistent volumes.

## Charts version

<!-- @import "VERSIONS.md" -->
See [VKPR Chart and Subchart versions](VERSIONS.md).

## Requisites

- Kubernetes >= 1.15
- Helm >= 3

## Contributing

Pull requests/Merge Requests are welcome! Please open an issue first and discuss with us about the proposing changes and be sure to perform tests in a proper way.

## Support

The support will be made by opening *Issues*. 
For corporate support, contact us.

## License

VKPR is licensed under the [Apache License Version 2.0](LICENSE).
