# meowhq-istio Helm Chart

Helm Chart for installing and configuring Istio Base and Istiod with Istio official Helm Charts as dependency,

<https://istio.io/latest/docs/setup/install/helm/>

- `istio/base`: Istio base chart which contains cluster-wide Custom Resource Definitions (CRDs) which must be installed prior to the deployment of the Istio control plane
- `istio/istiod`: Istio discovery chart which deploys the istiod service

## Configuration Values

please see [examples](examples/README.md) for more about usage and examples of values.

### Global Settings

Shared global settings for both istio base and istiod subchart.

- `global.istioNamespace` - Namespace where Istio components will be installed (default: istio-system). it is shared global value for both istio base and istiod subchart
- `global.imagePullSecrets` - Image pull secrets for accessing container registry (default: artifactory-registry). it is shared global value for both istio base and istiod subchart

### Istio Base Settings

For more detail: <https://github.com/istio/istio/blob/master/manifests/charts/base/values.yaml>

- `base.enabled` - Enable installation of Istio base chart (default: true)
- `base.profile` - istio profile to be applied (default: not defined). set `remote` for Remote cluster for Primary-Remote multicluster setup
- `base.defaultRevision` - Default revision for Istio installation (default: default)

### Istiod Settings

For more details: <https://github.com/istio/istio/blob/master/manifests/charts/istio-control/istio-discovery/values.yaml>

#### Global Istiod Configuration

- `istiod.enabled` - Enable installation of Istiod component (default: true)
- `istiod.profile` - istio profile to be applied (default: not defined). set `remote` for Remote cluster for Primary-Remote multicluster setup
- `istiod.global.configValidation` - Enable config validation (default: true)
- `istiod.global.priorityClass` - Priority class for Istiod pods (default: infra-critical)
- `istiod.global.caAddress` - CA address for istio-csr integration (default: "") this is for cert-manager-istio-csr integration.

#### Multicluster Configuration

- `istiod.global.meshID` - Mesh ID for multicluster setup (default: ""). no meshID required for Remote cluster. the `remote` profile will ignore in anyways.
- `istiod.global.network` - Network name for multicluster setup (default: "")
- `istiod.global.multiCluster.enabled` - Enable multicluster setup (default: false)
- `istiod.global.multiCluster.clusterName` - Name of the cluster in multicluster setup (default: "")
- `istiod.global.externalIstiod` - Enable control of remote clusters (default: false)
- `istiod.global.configCluster` - Configure as remote cluster for external istiod (default: false)

#### Proxy Configuration

- `istiod.global.proxy.logLevel` - Log level for sidecars (default: info)
- `istiod.global.proxy.resources.requests.cpu` - CPU requests for sidecar (default: 100m)
- `istiod.global.proxy.resources.requests.memory` - Memory requests for sidecar (default: 64Mi)
- `istiod.global.proxy.resources.limits.cpu` - CPU limits for sidecar (default: 200m)
- `istiod.global.proxy.resources.limits.memory` - Memory limits for sidecar (default: 128Mi)

#### Mesh Configuration

- `istiod.meshConfig.accessLogFile` - Access log file path (default: /dev/stdout)
- `istiod.meshConfig.enableTracing` - Enable distributed tracing (default: true)
- `istiod.meshConfig.defaultConfig.holdApplicationUntilProxyStarts` - Hold app start until proxy ready (default: true)

#### Pilot Configuration

- `istiod.pilot.autoscaleEnabled` - Enable autoscaling for istiod (default: true)
- `istiod.pilot.autoscaleMin` - Minimum replicas for istiod (default: 2)
- `istiod.pilot.cni.enabled` - Enable CNI plugin (default: true)
- `istiod.pilot.resources.requests.cpu` - CPU requests for istiod (default: 10m)
- `istiod.pilot.resources.requests.memory` - Memory requests for istiod (default: 100Mi)
