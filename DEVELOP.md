# Development <!-- omit in toc -->

Este documento explica como montar um ambiente para desenvolvimento do chart do vtg-ipaas.

- [Pré-requisitos](#pré-requisitos)
  - [Arquivo /etc/hosts](#arquivo-etchosts)
  - [Ferramentas](#ferramentas)
  - [Cluster k3d local](#cluster-k3d-local)
- [Local VKPR deployment](#local-vkpr-deployment)
  - [Get chart dependencies](#get-chart-dependencies)
  - [Helm upgrade/install](#helm-upgradeinstall)
  - [Testing local app](#testing-local-app)

## Pré-requisitos

### Arquivo /etc/hosts

Insira a linha abaixo no arquivo /etc/hosts da estação de desenvolvimento:

```
127.0.0.1 	whoami.localdomain
```

### Ferramentas

Instale localmente as seguintes ferramentas:

- k3d (versão 3.x ou superior)
- helm (v3 ou superior)
- kubectl

### Cluster k3d local

Crie um cluster k3d local para uso durante o desenvolvimento. Isto pode ser feito de duas formas:

* Usando o LB interno do k3d (forma preferida) - esta forma cria tanto um binding em `localhost:8080` quanto um IP na rede bridge para o ingress controller do VKPR:

```sh
k3d cluster create vkpr-local \
  -p "8080:80@loadbalancer" \
  -p "8443:443@loadbalancer" \
  --k3s-server-arg "--no-deploy=traefik"
```

* Usando NodePort - esta forma cria um binding em `localhost:8080` para o serviço que estiver no NodePort 32080 (este **não é** o defult do ingress controller do VKPR):

```sh
k3d cluster create vkpr-local \
  -p "8080:32080@agent[0]" --agents 1 \
  --k3s-server-arg "--no-deploy=traefik" \
  --k3s-server-arg "--no-deploy=servicelb"
```

Ambos os casos acima desligam o Traefik (ingress default do k3d), pois usaremos o Nginx Ingress Controller que é parte do VKPR. Após a criação do cluster ajuste o KUBECONFIG:

```sh
export KUBECONFIG=$(k3d kubeconfig write vkpr-local)
kubectl cluster-info 
```

## Local VKPR deployment

### Get chart dependencies

```sh
helm dependency update ./charts/vkpr
```

### Helm upgrade/install

```sh
helm upgrade -i vkpr --skip-crds -f ./examples/local/values-local-minimal.yaml ./charts/vkpr
```

Check the LoadBalancer external IP (might take a few seconds):

```sh
kubectl get svc
```

### Testing local app

```sh
# both tests are the same
curl whoami.localdomain:8080
curl -H "Host: whoami.localdomain" <EXTERNAL-IP>
```
