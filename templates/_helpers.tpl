{{/*
Expand the name of the chart.
*/}}
{{- define "cortex-layer-stack.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name for the layer.
*/}}
{{- define "cortex-layer-stack.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s-%s" .Values.layer.name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "cortex-layer-stack.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cortex-layer-stack.labels" -}}
helm.sh/chart: {{ include "cortex-layer-stack.chart" . }}
{{ include "cortex-layer-stack.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
cortex.ai/layer: {{ .Values.layer.name | quote }}
{{- with .Values.global.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cortex-layer-stack.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cortex-layer-stack.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
MoE Router name
*/}}
{{- define "cortex-layer-stack.moeRouter.name" -}}
{{- printf "%s-moe-router" .Values.layer.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Qdrant name
*/}}
{{- define "cortex-layer-stack.qdrant.name" -}}
{{- printf "%s-qdrant" .Values.layer.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
MCP Server name
*/}}
{{- define "cortex-layer-stack.mcpServer.name" -}}
{{- printf "%s-mcp" .Values.layer.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the image path
*/}}
{{- define "cortex-layer-stack.image" -}}
{{- $registry := .root.Values.global.registry -}}
{{- $repository := .image.repository -}}
{{- $tag := .image.tag | default "latest" -}}
{{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- end }}
