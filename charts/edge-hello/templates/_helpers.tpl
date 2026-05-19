{{/*
Expand the name of the chart.
*/}}
{{- define "edge-hello.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "edge-hello.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels applied to every resource.
*/}}
{{- define "edge-hello.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/name: {{ include "edge-hello.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
edge-hello/target: {{ .Values.app.target | quote }}
{{- end }}

{{/*
Selector labels — used by Service and Deployment to find each other.
*/}}
{{- define "edge-hello.selectorLabels" -}}
app.kubernetes.io/name: {{ include "edge-hello.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
