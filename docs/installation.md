# VKPR Installation

This document walks you through installing the VKPR on it.

## Installation and setup VKPR

### Step 1: Set up values

In this section, go to prepare values file to deploy VKPR in Cluster. A values file example find [here](../../examples).

All sub-charts specified into [Chart.yaml](../../vkpr/Chart.yaml) can be enabled/disabled in values with key `enabled`:

```yaml
nginx-ingress:
  enabled: true
```

By default is enabled the charts: [NGINX Ingress Controller](../stacks.md#nginx-ingress-controller), [Loki](../stacks.md#loki) and [Prometheus Operator](../stacks.md#prometheus-operator).

Example of the implementation of each sub-chart can be found in the [stack documentation](../stacks.md).

### Step 2: Deploy VKPR

With the values file finalized, let's deploy.

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

So that you can update the VKPR in the cluster, update the values file and apply:
```sh
helm upgrade -i -f values.yaml -n vkpr vkpr vertigo/vkpr
```

## Cleanup VKPR

To remove VKPR in a cluster, execute:
```sh
helm uninstall vkpr
```
