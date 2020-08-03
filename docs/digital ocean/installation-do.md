# VKPR Installation on Digital Ocean

This document walks you through a default VKPR installation. The following links guide you to the installation on specific clouds:

[EKS]()

[Digital Ocean]()

[GKE]()
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
helm install -f examples/values-do.yaml -n vkpr vkpr vertigo/vkpr
```

## Upgrading VKPR

In order to upgrade the VKPR in the cluster, update the values file and apply:
```sh
helm upgrade -i -f examples/values-do.yaml -n vkpr vkpr vertigo/vkpr
```

## Cleanup VKPR

To remove VKPR in a cluster, execute:
```sh
helm uninstall -n vkpr vkpr
```
Pay attention to Persistent Volumes that may have been left by some modules.

## External-DNS

Replace all `<DOMAIN_NAME>` occurrences in the values-do.yaml with your white card.
To set your DNS name in Digital Ocean you need to provide your Digital Ocean token in external-DNS installation like that:

```
helm upgrade -i vkpr -f example/values-do.yaml  vertigo/vkpr \
   --set external-dns.digitalocean.apiToken=$DO_AUTH_TOKEN
```
## Keycloak set up


TODO

## Velero set up

### Prerequisites
* A Kubernetes cluster running on DigitalOcean. It can be a managed cluster or self-hosted
* DigitalOcean account and resources
* [API personal access token](https://www.digitalocean.com/docs/api/create-personal-access-token/)
* [Spaces access keys](https://www.digitalocean.com/docs/spaces/how-to/administrative-access/)
* Spaces bucket
* Spaces bucket region
* [Velero](https://velero.io/docs/v1.2.0/basic-install/) v1.20 or newer & prerequisites

### Values variables to be set:

`<SPACES_KEY_ID>`  The Space Key ID created .

`<SPACES_SECRET_KEY_ID>` That Space's Secret Key.

`<SPACES_NAME>` The Space name.

`<SPACES_REGION>` Space's Region.

`<DIGITAL_OCEAN_TOKEN>` Your Digital Ocean Personal [Token](https://www.digitalocean.com/docs/apis-clis/api/create-personal-access-token/)

### Installation
Using Helm Hub's Velero chart v2.7.4

```
helm upgrade -i vkpr -n vkpr -f examples/values-do.yaml stable/vkpr  
```
Export the KUBECONFIG environment variable in order to point Velero cli to your EKS cluster and run the following command to set the namespace where Velero is installed. 

    
    velero client config set namespace=vkpr

### Snapshot configuration

1. Enable the `digitalocean/velero-plugin:v1.0.0` snapshot provider. This command will configure Velero to use the plugin for persistent volume snapshots.

    ```
    velero snapshot-location create default --provider digitalocean.com/velero
    ```

2. Patch the `velero` Kubernetes Deployment to expose your API token to the Velero pod(s). Velero needs this change in order to authenticate to the DigitalOcean API when manipulating snapshots:

    ```
    kubectl patch deployment vkpr-velero -p "$(cat velero-do-setup/02-velero-deployment.patch.yaml)" --namespace vkpr

Remember to set your KUBECONFIG in order to your velero cli interact with the cluster's installation.



## Testing

Docker Desktop already provides a kubernetes cluster for local tests:

```shell script
kubectl get nodes
NAME             STATUS   ROLES    AGE   VERSION
docker-desktop   Ready    master   12d   v1.14.7
```
Or maybe you are a Linux user, and then you can use [k3d](https://github.com/rancher/k3d) to local tests:

```shell script
k3d create -n vkpr-local \
  --publish="8000:32080" \
  --server-arg "--no-deploy=traefik" \
  --server-arg "--no-deploy=servicelb"
```
Another way is to make a minimal kubernetes cluster in Digital Ocean:

```shell script
doctl k8s cluster create my-cluster \
   --region nyc1 \
   --count=3 \
   --version 1.15.9-do.2 \
   --size=s-4vcpu-8gb
```

Or create the cluster in wherever cloud you want by using Terraform:

- [Make your Kubernetes cluster with Terraform modules!](https://gitlab.com/vertigobr/devops/terraform-modules)

## Clouds
- The External-DNS depends on credentials to update DNS records in your cloud provider. Instead of putting those credentials in open files you may want to pass it through command line: