{{/*
  read gateway.name from the istio gateway(subchart) chart helper
*/}}
{{- define "gatewayName" -}}
{{ template "gateway.name" .Subcharts.gateway }}
{{- end }}

{{/*
  read gateway.selectorLabels from the istio gateway(subchart) chart helper
*/}}
{{- define "gatewaySelectorLabelIstio" -}}
{{ (((.Values.gateway).labels).istio | default (include "gatewayName" . | trimPrefix "istio-") | quote) }}
{{- end }}
