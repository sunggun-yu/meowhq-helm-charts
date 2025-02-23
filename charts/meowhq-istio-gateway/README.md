# meowhq-istio-gateway Helm Chart

Helm Chart for installing and configuring Istio Ingress Gateway with Istio official Helm Charts as a dependency. It also includes configuring the `gateways.networking.istio.io` Istio Gateway.

refs:

- <https://istio.io/latest/docs/setup/install/helm/>
- <https://github.com/istio/istio/tree/master/manifests/charts/gateway>
- [Install Multi-Primary on different networks](https://istio.io/latest/docs/setup/install/multicluster/multi-primary_multi-network/)
- [Install Primary-Remote on different networks](https://istio.io/latest/docs/setup/install/multicluster/primary-remote_multi-network/)

___
Table of Contents:

- [Configuration Values](#configuration-values)
- [Istio Gateway Configuration](#istio-gateway-configuration)
  - [Global Settings](#global-settings)
  - [Default Gateway Settings](#default-gateway-settings)
  - [Multicluster Settings](#multicluster-settings)
- [Istio Ingress Gateway Deployment Configuration](#istio-ingress-gateway-deployment-configuration)
  - [Basic Settings](#basic-settings)
  - [Service Configuration](#service-configuration)
  - [Resource Management](#resource-management)
- [Examples](#examples)
  - [Adding additional ports in the Istio Gateway](#adding-additional-ports-in-the-istio-gateway)
  - [Multicluster](#multicluster)

## Configuration Values

please see [examples](examples/README.md) for more about usage and examples of values.

## Istio Gateway Configuration

### Global Settings

Global settings shares common variables across the ingress gateway configuration

- `global.istioGateway.apiVersion` - API version for Gateway resource (default: v1)
- `global.istioGateway.namespace` - Target namespace for Gateway deployment (default: default)

### Default Gateway Settings

The default Istio Gateway is configured with the default HTTPS listener server port. It is enabled by default and will be disabled if `multicluster` is enabled.

- `istioGateway.enabled` - creates Istio Gateway resource (default: true)
- `istioGateway.name` - Name of the Istio Gateway (default: ingress-gateway)
- `istioGateway.https.tlsMode` - TLS mode for the HTTPS listener (default: SIMPLE)
- `istioGateway.https.credentialName` - TLS credential name for default HTTPS listener (default: gkegatewaysecret)
- `istioGateway.https.hosts` - List of allowed hosts in default HTTPS listener (default: ["*"])
- `istioGateway.additionalServers` - Additional server listener port configurations for Istio Gateway

### Multicluster Settings

Enabling `multicluster` allows the creation and configuration of a general pattern for Multicluster Gateway Resources. It also disables the default Istio Gateway to create a dedicated Istio Ingress Gateway Deployment and Service.

- `multicluster.enabled` - Enable multicluster configuration (default: false)
- `multicluster.crossNetworkGateway.name` - Name of cross-network gateway
- `multicluster.crossNetworkGateway.hosts` - List of allowed hosts for cross-network gateway (default: ["*.local"])
- `multicluster.crossNetworkGateway.additionalServers` - Additional server configurations for cross-network gateway
- `multicluster.istiodGateway.enabled` - Enable istiod gateway for Primary-Remote setup (default: false)
- `multicluster.istiodGateway.name` - Name of istiod gateway
- `multicluster.istiodGateway.additionalServers` - Additional server configurations for istiod gateway

## Istio Ingress Gateway Deployment Configuration

This section provides configuration details for the official Istio Ingress Gateway Helm chart `gateway` used as a subchart. It sets default values for deploying the Istio Ingress Gateway following a general pattern.

<https://github.com/istio/istio/tree/master/manifests/charts/gateway>

> ⚠️ **INFO:**
>
> This configuration follows the official Istio Gateway Helm values. Please refer to the official documentation for more details and customization.
>
> <https://github.com/istio/istio/blob/1.24.0/manifests/charts/gateway/values.yaml>

### Basic Settings

- `gateway.name`: Name of the gateway deployment
- `gateway.imagePullSecrets`: Image pull secrets configuration (default: empty array)
- `gateway.revision`: Istio revision
- `gateway.labels.app`: App label value (default: null). it will be automatically generated and set from gateway.name unless you set the custom value
- `gateway.labels.istio`: Istio label value (default: null). it will be automatically generated and set from gateway.name unless you set the custom value

### Service Configuration

- `gateway.service.type`: Service type (default: LoadBalancer)
- `gateway.service.loadBalancerIP`: Load balancer IP address

### Resource Management

- `gateway.resources.requests.cpu`: CPU request (default: 200m)
- `gateway.resources.requests.memory`: Memory request (default: 256Mi)
- `gateway.autoscaling.enabled`: Enable autoscaling
- `gateway.autoscaling.minReplicas`: Minimum replicas (default: 2)
- `gateway.autoscaling.maxReplicas`: Maximum replicas (default: 8)

## Examples

### Adding additional ports in the Istio Gateway

```yaml
istioGateway:
  https:
    credentialName: my-cred
  additionalServers:
  - port:
      name: http
      number: 80
      protocol: HTTP
    tls:
      httpsRedirect: false
    hosts:
      - "*"
gateway:
  service:
    loadBalancerIP: "192.168.10.10"
```

### Multicluster

It follows the installation instruction:

- [Install Multi-Primary on different networks](https://istio.io/latest/docs/setup/install/multicluster/multi-primary_multi-network/)
- [Install Primary-Remote on different networks](https://istio.io/latest/docs/setup/install/multicluster/primary-remote_multi-network/)

```yaml
multicluster:
  enabled: true
gateway:
  name: istio-cross-network-gateway
  labels:
    app: cross-network-gateway
    istio: istio-cross-network-gateway
  networkGateway: meowhq-lab
  service:
    loadBalancerIP: "192.168.10.12"
```
