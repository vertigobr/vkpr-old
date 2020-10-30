![](https://img.shields.io/badge/status-In%20development-yellow)
![](https://img.shields.io/badge/license-Apache%202.0-blue)
![Release Helm chart](https://github.com/vertigobr/vkpr/workflows/Release%20Helm%20chart/badge.svg)
# VKPR - Vertigo Kubernetes Production Runtime

O VKPR é inspirado no [projeto BKPR](https://github.com/bitnami/kube-prod-runtime) da Bitnami, mas é implementado puramente com Helm charts.

[&#x1f1fa;&#x1f1f8; &#x1f1ec;&#x1f1e7; English](README.md) | [&#x1f1e7;&#x1f1f7; &#x1f1f5;&#x1f1f9; Português](README_pt.md)

## Descrição

O VKPR foi criado para simplificar a adoção de Kubernetes. Ele é composto por charts de terceiros, organizados de forma a suportar o uso de Kubernetes em produção com mínimo esforço.

O VKPR está estruturado em pilhas (*stacks*) que agrupam componentes que suportam uma funcionalidade correlata. As *stacks* atuais são:

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

## Instalação

A instalação do VKPR usa o [helm](https://helm.sh/):

```sh
helm repo add vertigo https://charts.vertigo.com.br
helm repo update
helm upgrade -i -f values.yaml -n vkpr vkpr vertigo/vkpr
```

Leia a [Documentação do VKPR](https://charts.vertigo.com.br/docs/) para estudar cenários específicos de instalação.

## Stacks

### Ingress stack
  
O **Ingress stack** foca em produzir formas de conexão externa aos recursos dentro do cluster Kubernetes.

- [NGINX Ingress Controller](https://charts.vertigo.com.br/docs/stacks#nginx-ingress-controller) é um Ingress Controller para Kubernetes que usa o NGINX como proxy reverso e balanceador de carga (*load balancer*).
- [ExternalDNS](https://charts.vertigo.com.br/docs/stacks#externaldns) é um componente para Kubernetes que configura automaticamente serviços de DNS públicos para que serviços do cluster possam ser descobertos por nomes DNS comuns.

### Logging stack

O **Logging Stack** cuida da coleta de logs distribuídos para posterior pesquisa.

- [Loki](https://charts.vertigo.com.br/docs/stacks#loki) é um sistema de coleta e agregação de logs inspirado no Prometheus que é escalável, disponível e multi-tenant.

### Monitoring stack

O **Monitoring Stack** é dedicado à observação e coleta de métricas tanto para o cluster como para serviços e aplicações individualmente.

- [Prometheus Operator](https://charts.vertigo.com.br/docs/stacks#prometheus-operator) permite instalar e gerenciar nativamente o Prometheus e seus componentes no Kubernetes. O Prometheus Operator contém os seguintes mídulos:
  - [Grafana](https://grafana.com/oss/grafana/) permite pesquisar e visualizar métricas e logs.
  - [Prometheus](https://grafana.com/oss/prometheus/) é um sistema de monitoração com um rico modelo de dados multidimensional, uma linguagem de pesquisa concisa e rica (PromQL), uma base de séries temporais eficiente, além de mais de 150 integrações com sistemas de terceiros.
  - [Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/) lida com alertas enviados por outras aplicações (entre elas o próprio Prometheus).

### Security stack

O **Security Stack** é focado em ferramentas de segurança que cuidam de questões onipresentes para sistemas (como gestão de identidade e segredos).

- [cert-manager](https://charts.vertigo.com.br/docs/stacks#cert-manager) é um componente para Kubernetes que automatiza a gestão e emissão de certificados TLS (HTTPS) por diversos emissores externos.
- [Vault](https://charts.vertigo.com.br/docs/stacks#vault) é uma solução que protege, armazena e restringe acesso a tokens, senhas, certificados, chaves de APIs e outros tantos elementos restritos típicos de sistemas modernos. 
- [Keycloak](https://charts.vertigo.com.br/docs/stacks#keycloak) é uma solução de código aberto para Gestão de Identidade e Acesso útil para aplicações e serviços modernos.

### Backup stack

O **Backup Stack** foca em ferramentas de backup e restore que auxiliam na migração e/ou restauração de um cluster e seus volumes.

- [Velero](https://charts.vertigo.com.br/docs/stacks#velero) é uma ferramenta de código aberto para backup e restore de clusters Kubernetes, sendo útil para *disaster recovery* e/ou migração de clusters e seus recursos.

## Versões dos charts

<!-- @import "VERSIONS.md" -->
Veja [Versões dos Charts e Subchart do VKPR](VERSIONS.md).

## Requisitos

- Kubernetes >= 1.15
- Helm >= 3

## Contribuindo

Pull requests e Merge Requests são bem-vindos! Por favor, primeiro abra uma issue e discuta conosco sobre a mudança proposta e tenha certeza que a testou previamente.

## Suporte

O suporte à comunidade se dará através de issues abertas.
Para suporte corporativo entre em contato com comercial@vertigo.com.br.

## Licença

VKPR é licenciado via [Apache License Version 2.0](LICENSE).
