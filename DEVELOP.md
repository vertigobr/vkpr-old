# Development

Este documento explica como montar um ambiente para desenvolvimento do chart do vtg-ipaas.

## Pré-requisitos

### Arquivo /etc/hosts

Insira a linha abaixo no arquivo /etc/hosts da estação de desenvolvimento:

```
127.0.0.1 	whoami.localdomain
```

### Ferramentas

Instale localmente as seguintes ferramentas:

- k3d
- helm
- kubectl

### Cluster k3d local

Crie um cluster k3d local para uso durante o desenvolvimento:

```sh
k3d create -n vkpr-local \
  --publish 8080:32080 \
  --server-arg "--no-deploy=traefik"
```

Os parâmetros acima desligam o Trefik (default do k3d), pois o Kong será o Ingress Controller.
Após a criação do cluster ajuste o KUBECONFIG:

```sh
export KUBECONFIG="$(k3d get-kubeconfig --name='vkpr-local')"
kubectl cluster-info 
```

## Local VKPR deployment

### Get chart dependencies

```sh
cd charts/vkpr
helm dependency update
cd ../..
```

### Helm upgrade/install

```sh
helm upgrade -i vkpr -f ./examples/values-local.yaml ./charts/vkpr
```

