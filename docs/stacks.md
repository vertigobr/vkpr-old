# VKPR stacks

- **[Ingress stack](#ingress-stack):**
  - [NGINX Ingress Controller](#nginx-ingress-controller)
  - [ExternalDNS](#externaldns)
- **[Logging stack](#logging-stack):**
  - [Loki](#loki)
- **[Monitoring stack](#monitoring-stack):**
  - [Prometheus Operator](#prometheus-operator)
    - Grafana
    - Prometheus
    - Alertmanager
- **[Security stack](#security-stack):**
  - [cert-manager](#cert-manager)
  - [Vault](#vault)
  - [Keycloak](#keycloak)
- **[Backup stack](#backup-stack):**
  - [Velero](#velero)

## Ingress stack

### NGINX Ingress Controller

[ingress-nginx](https://github.com/kubernetes/ingress-nginx) is an Ingress controller for Kubernetes using NGINX as a reverse proxy and load balancer.

Ingress exposes HTTP and HTTPS routes from outside the cluster to services within the cluster. An Ingress resource supports exposing services and configuring TLS termination for each exposed host name.

#### Implementation

By default the **NGINX Ingress Controller** is enabled in *VKPR* installation. An example of configuration :

```yaml
nginx-ingress:
  enabled: true
  controller:
    publishService:
      enabled: true
    autoscaling:
      enabled: true
      minReplicas: 1
      maxReplicas: 3
```

To see more configurations, access the [documentation](https://github.com/helm/charts/tree/master/stable/nginx-ingress#configuration). 

### ExternalDNS

[ExternalDNS](https://github.com/kubernetes-sigs/external-dns) is a Kubernetes addon that configures public DNS servers with information about exposed Kubernetes services to make them discoverable.

Inspired by [Kubernetes DNS](https://github.com/kubernetes/dns), Kubernetes' cluster-internal DNS server, ExternalDNS makes Kubernetes resources discoverable via public DNS servers. Like KubeDNS, it retrieves a list of resources (Services, Ingresses, etc.) from the [Kubernetes API](https://kubernetes.io/docs/concepts/overview/kubernetes-api/) to determine a desired list of DNS records. Unlike KubeDNS, however, it's not a DNS server itself, but merely configures other DNS providers accordingly—e.g. [AWS Route 53](https://aws.amazon.com/route53/) or [Google Cloud DNS](https://cloud.google.com/dns/docs/).

#### Implementation

By default the **ExternalDNS** is disabled in *VKPR* installation. An example of configuration:

```yaml
external-dns:
  enabled: true
  rbac:
    create: true
  sources:
    - ingress
    - service
  provider: digitalocean
  interval: "1m"
```

To see more configurations, access the [documentation](https://github.com/bitnami/charts/tree/master/bitnami/external-dns#parameters). 

## Logging stack

### Loki

[Loki](https://github.com/grafana/loki) is a horizontally-scalable, highly-available, multi-tenant log aggregation system inspired by [Prometheus](https://prometheus.io/). It is designed to be very cost effective and easy to operate. It does not index logs content, but rather a set of labels for each log stream.

#### Implementation

By default the **Loki** is enabled in *VKPR* installation. An example of configuration:

```yaml
loki-stack:
  enabled: true
  serviceScheme: https
```

To see more configurations, access the [documentation](https://github.com/grafana/loki/tree/master/production/helm).

## Monitoring stack

### Prometheus Operator

[Prometheus Operator](https://github.com/coreos/prometheus-operator) provides Kubernetes native deployment and management of [Prometheus](https://prometheus.io/) and related monitoring components. The purpose of this project is to simplify and automate the configuration of a Prometheus based monitoring stack for Kubernetes clusters.

Prometheus Operator contains the following modules:

- **[Grafana](https://github.com/grafana/grafana)** allows you to query, visualize, alert on and understand your metrics no matter where they are stored.

- **[Prometheus](https://prometheus.io/)** scrapes metrics from instrumented jobs, either directly or via an intermediary push gateway for short-lived jobs. It stores all scraped samples locally and runs rules over this data to either aggregate and record new time series from existing data or generate alerts.

- **[Alertmanager](https://github.com/prometheus/alertmanager)** handles alerts sent by client applications such as the Prometheus server. It takes care of deduplicating, grouping, and routing them to the correct receiver integrations such as email, PagerDuty, or OpsGenie. It also takes care of silencing and inhibition of alerts.

#### Implementation

By default the **Prometheus Operator** is enabled in *VKPR* installation. An example of configuration:

```yaml
prometheus-operator:
  enabled: true
  prometheusOperator:
    createCustomResource: false
  grafana:
    adminPassword: "password"
    ingress:
      enabled: true
      annotations:
        kubernetes.io/ingress.class: nginx
        kubernetes.io/tls-acme: "true"
      hosts: ["grafana.whoami.com"]
```

To see more configurations, access the [documentation](https://github.com/helm/charts/tree/master/stable/prometheus-operator#general).

## Security stack

### cert-manager

[cert-manager](https://github.com/jetstack/cert-manager) is a Kubernetes addon to automate the management and issuance of TLS certificates from various issuing sources.

It will ensure certificates are valid and up to date periodically, and attempt to renew certificates at an appropriate time before expiry.

#### Implementation

By default the **cert-manager** is disabled in *VKPR* installation. An example of configuration:

```yaml
cert-manager:
  enabled: true
  ingressShim:
    defaultIssuerName: letsencrypt-production
    defaultIssuerKind: ClusterIssuer
    defaultIssuerGroup: cert-manager.io
```

To see more configurations, access the [documentation](https://github.com/jetstack/cert-manager/blob/master/deploy/charts/cert-manager/README.template.md#configuration).

### Vault

[Vault](https://github.com/hashicorp/vault) is a tool for securely accessing secrets. A secret is anything that you want to tightly control access to, such as API keys, passwords, certificates, and more. Vault provides a unified interface to any secret, while providing tight access control and recording a detailed audit log.

A modern system requires access to a multitude of secrets: database credentials, API keys for external services, credentials for service-oriented architecture communication, etc. Understanding who is accessing what secrets is already very difficult and platform-specific. Adding on key rolling, secure storage, and detailed audit logs is almost impossible without a custom solution. 

#### Implementation

By default the **Vault** is disabled in *VKPR* installation. An example of configuration:

```yaml
vault:
  enabled: true
  server:
    ha:
      enabled: true
      raft:
        enabled: true
```

To see more configurations, access the [documentation](https://github.com/hashicorp/vault-helm).

### Keycloak

[Keycloak](https://github.com/keycloak/keycloak) is an Open Source Identity and Access Management solution for modern Applications and Services.

#### Implementation

By default the **Keycloak** is disabled in *VKPR* installation. An example of configuration:

```yaml
keycloak:
  enabled: true
  keycloak:
    username: keycloak
    password: admin123
```

To view more configuration, access the [documentation](https://github.com/codecentric/helm-charts/tree/master/charts/keycloak#configuration).

## Backup stack

### Velero

[Velero](https://github.com/vmware-tanzu/velero) gives you tools to back up and restore your Kubernetes cluster resources and persistent volumes.

#### Implementation

By default **Velero** is disabled in *VKPR* installation. An example of configuration:

```yaml
velero:
  enabled: true
  initContainers: 
    - name: velero-plugin-for-aws
      image: velero/velero-plugin-for-aws:v1.0.0
      imagePullPolicy: IfNotPresent
      volumeMounts:
        - mountPath: /target
          name: plugins
```

To see more configurations, access the [documentation](https://github.com/vmware-tanzu/helm-charts/tree/main/charts/velero).
