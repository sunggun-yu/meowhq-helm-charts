# Vault

TODO: remove me later

## Enable K8s Auth

> ref: <https://learn.hashicorp.com/tutorials/vault/kubernetes-sidecar?in=vault/kubernetes>

attach vault-0 container to run vault command inside it:

```bash
# switch to vault ns
kubens vault
# attach container
kubectl exec -it vault-0 -- sh
# and login since instance is not dev mode
vault login
```

enable kubernetes auth:

```bash
vault auth enable kubernetes
```

configure kubernetes auth method:

```bash
vault write auth/kubernetes/config \
    kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
    token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
    issuer="https://kubernetes.default.svc.cluster.local"
```

> - `$KUBERNETES_PORT_443_TCP_ADDR` is exported in the pod
> - service account token is mounted at `/var/run/secrets/kubernetes.io/serviceaccount/token`
> - cluster ca cert is mounted at `/var/run/secrets/kubernetes.io/serviceaccount/ca.crt`
> - `@` reads file content as text

create the policy:

```bash
vault policy write internal - <<EOF
path "internal/*" {
  capabilities = ["read"]
}
EOF
```

> policy allow read all children path under `internal` by setting path `internal/*`

create the k8s auth role:

```bash
vault write auth/kubernetes/role/internal \
  bound_service_account_names="*" \
  bound_service_account_namespaces="*" \
  policies=internal \
  ttl=24h
```

> set `*` for `bound_service_account_names` and `bound_service_account_namespaces`. so vault-agent can inject secret for any sa and ns

### Test

> ref: <https://www.vaultproject.io/docs/platform/k8s/injector/examples>

#### set secret in the file

Create Deployment with vault-agent inject annotations:

```bash
kubectl apply -f - <<EOF
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vault-test-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vault-test-app
  template:
    metadata:
      labels:
        app: vault-test-app
      annotations:
        vault.hashicorp.com/agent-inject: 'true'
        vault.hashicorp.com/role: 'internal'
        vault.hashicorp.com/agent-inject-secret-database-config.txt: 'internal/test'
        vault.hashicorp.com/agent-inject-template-database-config.txt: |
          {{- with secret "internal/test" -}}
          postgresql://{{ .Data.data.id }}:{{ .Data.data.pw }}@postgres:5432/wizard
          {{- end -}}
    spec:
      serviceAccountName: default
      containers:
        - name: app
          image: busybox
          command: ['sh', '-c', 'echo "running" && sleep 3600']
EOF
```

check the result:

```bash
kubectl exec -it <pod-name> -- cat /vault/secrets/database-config.txt
```

- secret will be created as file by `vault.hashicorp.com/agent-inject-secret-database-config.txt`
- `database-config.txt` is the file name
- file path will be under `/vault/secrets/`
- file content will be formatted by `vault.hashicorp.com/agent-inject-template-database-config.txt`

#### set secret in the environment variables

> Actually, not useful. better to use banzai or integrate ArgoCD with Vault

```bash
kubectl apply -f - <<EOF
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vault-test-app-2
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vault-test-app-2
  template:
    metadata:
      labels:
        app: vault-test-app-2
      annotations:
        vault.hashicorp.com/agent-inject: 'true'
        vault.hashicorp.com/role: 'internal'
        vault.hashicorp.com/agent-inject-secret-config: 'internal/test'
        # Environment variable export template
        vault.hashicorp.com/agent-inject-template-config: |
          {{ with secret "internal/test" -}}
          export api_key="{{ .Data.data.id }}"
          export api_secret="{{ .Data.data.pw }}"
          {{- end }}
    spec:
      serviceAccountName: default
      containers:
        - name: app
          image: busybox
          command: ['sh', '-c', 'source /vault/secrets/config && echo $api_key && echo "running" && sleep 3600']
EOF
```

## Enable Gitlab OIDC

export vault addr:

```bash
export VAULT_ADDR=https://vault.meowhq.yufam.net
```

login to vault server:

```bash
vault login
```

enable oidc:

```bash
vault auth enable oidc
```

write oidc role:

```bash
vault write auth/oidc/role/default \
   user_claim="email" \
   allowed_redirect_uris="https://vault.meowhq.yufam.net/ui/vault/auth/oidc/oidc/callback" \
   allowed_redirect_uris="http://localhost:8250/oidc/callback" \
   allowed_redirect_uris="http://127.0.0.1:8250/oidc/callback" \
   groups_claim="groups" \
   oidc_scopes="openid,profile,email" \
   policies=default \
   bound_audiences="<client-id>"
```

> ensure `http://localhost(or 127.0.0.1):8250/oidc/callback` for cli

```bash
vault login -method=oidc
```

write oidc config:

```bash
vault write auth/oidc/config \
    oidc_discovery_url="https://gitlab.com" \
    oidc_client_id="<client-id>" \
    oidc_client_secret="<client-secret>" \
    default_role="default" \
    bound_issuer="vault.meowhq.yufam.net"
```

## Create Admin Policy

policy name: admin

```hcl
# R/W access to the intermediate CA paths
path "pki/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# R/W access to the KV backends
path "kv/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# R/O access to secret mounts
path "sys/mounts" {
  capabilities = ["read", "list"]
}

# R/O access to secret mounts
path "sys/mounts/*" {
  capabilities = ["read", "list"]
}

# R/O access to auth methods
path "auth/*" {
  capabilities = ["read", "list"]
}

# R/O access to auth methods
path "sys/auth" {
  capabilities = ["read", "list"]
}

# R/O access to auth methods
path "sys/auth/*" {
  capabilities = ["read", "list"]
}

# R/O access to policies
path "sys/policies/acl" {
  capabilities = ["read", "list"]
}

# R/O access to policies
path "sys/policies/acl/*" {
  capabilities = ["read", "list"]
}

# R/W access to identities
path "identity/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Disables self promotion to and deletion of super admins group
path "identity/group/id/0972caa9-c06c-5392-4d83-cf5da619f6fb" {
  capabilities = ["read", "list"]
}

# Disables self promotion to and deletion of provisioners group
path "identity/group/id/d849bf06-037c-7a0f-5669-00e13742ca33" {
  capabilities = ["read", "list"]
}

# Read health checks
path "sys/health" {
  capabilities = ["read", "sudo"]
}

# List existing audit devices
path "sys/audit" {
  capabilities = ["read", "list", "sudo"]
}
```
