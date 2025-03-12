# Examples

## normal installation

just install with default values for normal and non-multicluster configuration.

## use another priority class

values.yaml:

```yaml
istiod:
  global:
    priorityClass: something-else
```

following also works:

```yaml
global:
  priorityClass: something-else
```

## Multicluster example

prerequisites of following example:

- `cert-manager-istio-csr` chart installed
- Vault PKI engine is integrated

### Multi-Primary on different networks example

> ref: <https://istio.io/latest/docs/setup/install/multicluster/multi-primary_multi-network/>

values.yaml: in all clusters in the mesh cluster

```yaml
istiod:
  global:
    caAddress: "cert-manager-istio-csr.istio-system.svc:443"
    meshID: "mesh1"
    network: "network1"
    multiCluster:
      enabled: true
      clusterName: "cluster1"
  meshConfig:
    defaultConfig:
      proxyMetadata:
        # Enable basic DNS proxying
        ISTIO_META_DNS_CAPTURE: "true"
        # Enable automatic address allocation, optional
        ISTIO_META_DNS_AUTO_ALLOCATE: "true"
  pilot:
    env:
      ENABLE_CA_SERVER: false
```

### Primary-Remote on different networks example

Primary-Remote consists of Primary and Remote clusters, and the configuration is slightly different between them.

> ⚠️ INFO:
>
> - ensure the Istio cross-network gateway is configured for each primary / remote cluster
> - some manual configuration may be required to set label/annotation to istio-system namespace
>
> ref: <https://istio.io/latest/docs/setup/install/multicluster/primary-remote_multi-network/>

#### Primary

> ref: <https://istio.io/latest/docs/setup/install/multicluster/primary-remote_multi-network/#configure-cluster1-as-a-primary>

values.yaml:

```yaml
istiod:
  global:
    caAddress: "cert-manager-istio-csr.istio-system.svc:443"
    meshID: "mesh1"
    network: "network1"
    multiCluster:
      enabled: true
      clusterName: "cluster1"
    externalIstiod: true
  meshConfig:
    defaultConfig:
      proxyMetadata:
        # Enable basic DNS proxying
        ISTIO_META_DNS_CAPTURE: "true"
        # Enable automatic address allocation, optional
        ISTIO_META_DNS_AUTO_ALLOCATE: "true"
  pilot:
    env:
      ENABLE_CA_SERVER: false
```

#### Remote

> ref: <https://istio.io/latest/docs/setup/install/multicluster/primary-remote_multi-network/#configure-cluster2-as-a-remote>

values.yaml:

> ⚠️ INFO:
>
> - no meshID for Remote cluster

```yaml
base:
  profile: remote
istiod:
  profile: remote
  global:
    caAddress: "cert-manager-istio-csr.istio-system.svc:443"
    network: "network2"
    multiCluster:
      enabled: true
      clusterName: "cluster2"
    configCluster: true
    remotePilotAddress: 192.168.10.20 # loadbalancer ip of primary cluster cross-network-gateway svc
  istiodRemote:
    injectionPath: /inject/cluster/cluster1/net/network1
  pilot:
    env:
      ENABLE_CA_SERVER: false
```

you can get loadbalancer ip of primary cluster:

```bash
# ensure you are in primary cluster context
kubectl -n istio-system get svc istio-cross-network-gateway \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```
