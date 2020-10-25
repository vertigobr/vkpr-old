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

vault_init_http:
	kubectl exec vkpr-vault-0 -- vault operator init -key-shares=1 -key-threshold=1 -format=json > init-keys.json
	kubectl exec vkpr-vault-0 -- vault operator unseal $$(cat init-keys.json | jq -r ".unseal_keys_b64[]")

VAULT_ADDR := http://vkpr-vault.default.svc
vault_setup_http:
	vault login $$(cat init-keys.json | jq -r ".root_token")
	echo 'path "/secret/*" { capabilities = ["read", "list"] }' | vault policy write reader -
	vault auth enable oidc
	vault write auth/oidc/config \
		oidc_discovery_url="http://vkpr-keycloak-http.default.svc/auth/realms/vkpr" \
		oidc_client_id="oidc-demo" \
		oidc_client_secret="60e50da1-b492-4995-9574-763fa285456c" \
		default_role="reader"
	vault write auth/oidc/role/reader \
		bound_audiences="oidc-demo" \
		allowed_redirect_uris="http://vkpr-vault.default.svc/ui/vault/auth/oidc/oidc/callback" \
		allowed_redirect_uris="http://localhost:8250/oidc/callback" \
		user_claim="sub" policies="reader"

# abaixo foi Kayke
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
keycloak_local_up:
	k3d cluster create vkpr-local -p "8080:80@loadbalancer" -p "8443:443@loadbalancer" --k3s-server-arg "--no-deploy=traefik"
	export KUBECONFIG=$(k3d kubeconfig write vkpr-local)
	kubectl create secret generic vkpr-realm-secret --from-file=examples/keycloak/realm.json
	helm upgrade -i vkpr --skip-crds -f examples/local/values-local-keycloak.yaml ./charts/vkpr
	docker-compose -f examples/keycloak/docker-compose.yml up -d
	echo "Open http://localhost:5443/ on your browser and check integration with keycloak using the login/password defined on the realm"

vault_keycloak_local_up:
	k3d cluster create vkpr-local --k3s-server-arg "--no-deploy=traefik"
	export KUBECONFIG=$$(k3d kubeconfig write vkpr-local)
	kubectl create secret generic digitalocean-dns --from-literal=access-token=${DO_TOKEN}
	kubectl create secret generic vkpr-realm-secret --from-file=examples/keycloak/realm.json
	helm upgrade -i vkpr --skip-crds -f examples/local/values-local-vault.yaml ./charts/vkpr --set external-dns.digitalocean.apiToken=${DO_TOKEN}

vault_keycloak_local_http_up:
	k3d cluster create vkpr-local --k3s-server-arg "--no-deploy=traefik"
	export KUBECONFIG=$$(k3d kubeconfig write vkpr-local)
	kubectl create secret generic vkpr-realm-secret --from-file=examples/keycloak/realm.json
	helm upgrade -i vkpr --skip-crds -f examples/local/values-local-vault-http.yaml ./charts/vkpr
	echo "Detecting LoadBalancer external IP"
	export LB_IP=""; \
	while [ -z "$${LB_IP}" ]; do \
		export LB_IP=$$(kubectl get svc vkpr-ingress-nginx-controller -o jsonpath="{.status.loadBalancer.ingress[*].ip}"); \
		if [ -z "$${LB_IP}" ]; then \
			echo "Waiting for LoadBalancer external IP..."; \
			sleep 3; \
		else \
			echo "LoadBalancer external IP: $${LB_IP}"; \
			echo "Hacking into /etc/hosts, gonna need sudo, please."; \
			if grep -q "vkpr-keycloak-http" /etc/hosts; then \
				sudo sed "s/.*vkpr-keycloak-http.*/$${LB_IP} vkpr-vault.default.svc vkpr-keycloak-http.default.svc/g" -i /etc/hosts; \
			else \
				sudo sh -c 'echo "$${LB_IP} vkpr-vault.default.svc vkpr-keycloak-http.default.svc" >> /etc/hosts'; \
			fi; \
		fi; \
	done

vault_keycloak_local_configure:
	kubectl apply -f examples/local/acme.yaml