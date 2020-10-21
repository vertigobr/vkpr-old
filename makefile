add:
	kubectl create ns vkpr || true
	helm upgrade -i -f examples/values-aws.yaml -n vkpr vkpr ./vkpr --set external-dns.digitalocean.apiToken=$$(keybase decrypt -i ~/Documents/cloud-credentials/do.encrypt)

local:
	kubectl create ns vkpr || true
	helm upgrade -i vkpr -n vkpr -f examples/values-local.yaml ./vkpr

del:
	helm uninstall vkpr -n vkpr
	kubectl delete --all pvc -n vkpr

secret_del:
	kubectl delete secret vkpr-realm-secret -n vkpr
	rm ./vkpr-realm.json
## VAULT SETUP ##

vault_init_dev:
	kubectl exec vkpr-vault-0 -n vkpr -- vault operator init -key-shares=1 -key-threshold=1 -format=json > init-keys.json
	kubectl exec -n vkpr vkpr-vault-0 -- vault operator unseal $$(cat init-keys.json | jq -r ".unseal_keys_b64[]")

vault_raft_1:
	kubectl exec -n vkpr -ti vkpr-vault-1 -- vault operator raft join http://vkpr-vault-0.vkpr-vault-internal:8200
	kubectl exec -n vkpr vkpr-vault-1 -- vault operator unseal $$(cat init-keys.json | jq -r ".unseal_keys_b64[]")

vault_raft_2:
	kubectl exec -n vkpr -ti vkpr-vault-2 -- vault operator raft join http://vkpr-vault-0.vkpr-vault-internal:8200
	kubectl exec -n vkpr vkpr-vault-2 -- vault operator unseal $$(cat init-keys.json | jq -r ".unseal_keys_b64[]")


## vault OIDC ##
vault_oidc_enable:
	vault auth enable oidc

secret_gen:
	ls ./realms
	read REALM ; cp ./realms/$$REALM ./vkpr-realm.json; diff ./realms/$$REALM ./vkpr-realm.json
	kubectl create secret -n vkpr generic vkpr-realm-secret --from-file=vkpr-realm.json
vault_oidc_disable:
	vault auth disable oidc

template:
	kubectl create ns vkpr || true
	helm template vkpr -n vkpr -f examples/values-local.yaml ./vkpr | kubectl apply -f -
vault_oidc_config:
	vault write auth/oidc/config oidc_discovery_url="https://gitlab.com" oidc_client_id=$$(keybase decrypt -i ./client_id) oidc_client_secret=$$(keybase decrypt -i ./secret_id) default_role="demo" bound_issuer="localhost"

template_del:
	helm template vkpr -n vkpr -f examples/values-local.yaml ./vkpr | kubectl delete -f -
vault_oidc_role:
	vault write auth/oidc/role/demo user_claim="sub" allowed_redirect_uris="http://localhost:8250/oidc/callback,http://127.0.0.1:8200/ui/vault/auth/oidc/oidc/callback" bound_audiences=$$(keybase decrypt -i ./client_id)  role_type="oidc" oidc_scopes="openid"  policies=demo ttl=1h

## vault PKI ##
vault_pki_enable:
	vault secrets enable pki
vault_pki_tune:
	vault secrets tune -max-lease-ttl=8760h pki

vault_pki_root_cert:
	vault write pki/root/generate/internal common_name=example.com ttl=8760h

vault_pki_config:
	vault write pki/config/urls issuing_certificates="http://vkpr-vault.vkpr:8200/v1/pki/ca" crl_distribution_points="http://vkpr-vault.vkpr:8200/v1/pki/crl"

vault_pki_role:
	vault write pki/roles/example-dot-com allowed_domains=example.com allow_subdomains=true max_ttl=72h

vault_oki_issuer_sa:
	kubectl create serviceaccount issuer

vault_pki_policy:
	vault policy write pki vault/policies/pki.hcl

!vault_pki_issuer_example:
	ISSUER_SECRET_REF=$$(kubectl get serviceaccount issuer -o json | jq -r ".secrets[].name")
	kubectl apply -f vault/pki/issuers/example-com.yml

## vault K8S auth ##

vault_k8s_enable:
	vault auth enable kubernetes

vault_k8s_config:
	vault write auth/kubernetes/config token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

vault_k8s_role:
	vault write auth/kubernetes/role/issuer bound_service_account_names=issuer bound_service_account_namespaces=default policies=pki ttl=20m

## Run keycloak locally with k3d
keycloak_local:
	k3d cluster create vkpr-local -p "8080:80@loadbalancer" -p "8443:443@loadbalancer" --k3s-server-arg "--no-deploy=traefik"
	export KUBECONFIG=$(k3d kubeconfig write vkpr-local)
	kubectl create secret generic realm-secret --from-file=examples/keycloak/realm.json
	helm upgrade -i vkpr --skip-crds -f examples/local/values-local-keycloak.yaml ./charts/vkpr
