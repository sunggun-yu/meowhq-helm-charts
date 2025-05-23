{{/*
  read gateway.selectorLabels from the istio gateway(subchart) chart helper
  the default value in values.yaml for gateway chart should be initialized with null to avoid nil pointer
  ```yaml
  gateway:
    labels:
      app: null
      istio: null
  ```
*/}}
{{- define "gatewaySelectorLabel" -}}
{{ template "gateway.selectorLabels" .Subcharts.gateway }}
{{- end }}

{{/*
  convert gateway.selectorLabels from the istio gateway(subchart) chart helper to dict and pick istio label value
  and use it in the gateway selector
*/}}
{{- define "gatewaySelectorLabelIstio" -}}
{{- $dict := include "gatewaySelectorLabel" . | fromYaml -}}
{{ $dict.istio }}
{{- end -}}

{{/*
  use the istioGatewayName same as gatewaySelectorLabelIstio convention.
  so, if the release name is istio-ingressgateway, then the istioGateway.name will be ingressgateway by default if istioGateway.name is not set in values.yaml
*/}}
{{- define "istioGatewayName" -}}
{{ .Values.istioGateway.name | default (include "gatewaySelectorLabelIstio" .) }}
{{- end -}}
