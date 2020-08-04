# VKPR - Vertigo Kubernetes Production Runtime

VKPR is inspired in the [BKPR project](https://github.com/bitnami/kube-prod-runtime) but it's handed over through Helm chart.

## Description

VKPR was developed to make Kubernetes easier to use. It is composed of third-party sets, organized to deliver a production-ready Kubernetes with minimal effort.

## Installation

The VKPR installation uses [helm](https://helm.sh/):

```sh
helm repo add vertigo https://vertigobr.github.io/vkpr
helm repo update
helm upgrade -i -f values.yaml -n vkpr vkpr vertigo/vkpr
```

Take a look on [docs](https://vertigobr.github.io/vkpr/docs/) to check the installation for a more specific scenario.
