# VKPR Installation

This document walks you through installing the VKPR on it.

## Installation and setup VKPR

### Step 1: Set up values

In this section, we are going to prepare a values file to deploy VKPR in the Cluster. A values file example can be found [here](../../examples).

All sub-charts specified into [Chart.yaml](../../vkpr/Chart.yaml) can be enabled/disabled in values with the following key `enabled`:

```yaml
nginx-ingress:
  enabled: true
```

The charts: [NGINX Ingress Controller](../stacks.md#nginx-ingress-controller), [Loki](../stacks.md#loki) and [Prometheus Operator](../stacks.md#prometheus-operator) are enabled by default.

An example of the implementation of each sub-chart can be found in the [stack documentation](../stacks.md).

### Step 2: Deploy VKPR

With the values file concluded, let's deploy it.

First, add helm repository:
```sh
helm repo add vertigo https://vertigobr.github.io/vkpr
helm repo update
```

Then, deploy VKPR:
```sh
helm install -f values.yaml -n vkpr vkpr vertigo/vkpr
```

## Upgrading VKPR

In order to upgrade the VKPR in the cluster, update the values file and apply:
```sh
helm upgrade -i -f values.yaml -n vkpr vkpr vertigo/vkpr
```

## Cleanup VKPR

To remove VKPR in a cluster, execute:
```sh
helm uninstall vkpr
```
