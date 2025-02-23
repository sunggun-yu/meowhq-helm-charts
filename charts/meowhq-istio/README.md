# meowhq-istio Helm Chart

Helm Chart for installing and configuring Istio Base and Istiod with Istio official Helm Charts as dependency,

<https://istio.io/latest/docs/setup/install/helm/>

- `istio/base`: Istio base chart which contains cluster-wide Custom Resource Definitions (CRDs) which must be installed prior to the deployment of the Istio control plane
- `istio/istiod`: Istio discovery chart which deploys the istiod service

## Multicluster Config Example

### Multi-Primary

It follows the installation instruction:

- [Install Multi-Primary](https://istio.io/latest/docs/setup/install/multicluster/multi-primary/)
- [Install Multi-Primary on different networks](https://istio.io/latest/docs/setup/install/multicluster/multi-primary_multi-network/)

Helm values example:

```yaml
# =============================================================================
# istiod Helm Chart configuration
# =============================================================================
istiod:
  global:
    meshID: "meowhq-lab-mesh"
    network: "meowhq-lab"
    multiCluster:
      enabled: true
      clusterName: "meowhq"
```

### Primary-Remote

It follows the installation instruction:

- [Install Primary-Remote](https://istio.io/latest/docs/setup/install/multicluster/primary-remote/)
- [Install Primary-Remote on different networks](https://istio.io/latest/docs/setup/install/multicluster/primary-remote_multi-network/)

Helm values example:

```yaml
# =============================================================================
# istiod Helm Chart configuration
# =============================================================================
istiod:
  global:
    meshID: "meowhq-lab-mesh"
    network: "meowhq-lab"
    externalIstiod: true # when expose istiod to external - primary-remote setup
    multiCluster:
      enabled: true
      clusterName: "meowhq"
```
