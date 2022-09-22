# ------------------------------------ CHART NAME ---------------------------- #
{{/*
    Define expanded chart's name
*/}}
{{- define "chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}
# ----------------------------------- /CHART NAME ---------------------------- #




# ----------------------------------- API VERSION ---------------------------- #
{{/*
Return the appropriate apiVersion for deployment.
*/}}
{{- define "chart.server.deployment.apiVersion" -}}
{{- print "apps/v1" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for service.
*/}}
{{- define "chart.server.service.apiVersion" -}}
{{- print "v1" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "chart.server.ingress.apiVersion" -}}
{{- print "networking.k8s.io/v1" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for secrets.
*/}}
{{- define "chart.server.secret.apiVersion" -}}
{{- print "v1" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for config maps.
*/}}
{{- define "chart.server.configMap.apiVersion" -}}
{{- print "v1" -}}
{{- end -}}
# ----------------------------------- /API VERSION --------------------------- #




# ------------------------------------ APP NAME ------------------------------ #
{{/*
    Create a default fully qualified app name.
    We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "chart.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
    Create a default fully qualified name for the blog component.
    We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "chart.server.fullname" -}}
{{- if .Values.server.fullnameOverride -}}
{{- .Values.server.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.server.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.server.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}
# ----------------------------------- /APP NAME ------------------------------ #




# -------------------------------- APP NAMESPACE ----------------------------- #
{{/*
    Define the chart.namespace template if set with forceNamespace or .Release.Namespace is set
*/}}
{{- define "chart.namespace" -}}
{{- if .Values.forceNamespace -}}
{{ printf "namespace: %s" .Values.forceNamespace }}
{{- else -}}
{{ printf "namespace: %s" .Release.Namespace }}
{{- end -}}
{{- end -}}
# -------------------------------- /APP NAMESPACE ---------------------------- #




# ------------------------------------ LABELS -------------------------------- #
{{/*
    Create chart name and version as used by the chart label.
*/}}
{{- define "chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
    Create unified labels for chart components
*/}}
{{- define "chart.common.matchLabels" -}}
app: "{{ template "chart.name" . }}"
release: "{{ .Release.Name }}"
{{- end -}}

{{- define "chart.common.metaLabels" -}}
chart: "{{ template "chart.chart" . }}"
heritage: "{{ .Release.Service }}"
{{- end -}}

{{/*
    Create unified match labels for components
*/}}
{{- define "chart.server.matchLabels" -}}
component: {{ .Values.server.name | quote }}
{{ include "chart.common.matchLabels" . }}
{{- end -}}

{{/*
    Create unified labels for components
*/}}
{{- define "chart.server.labels" -}}
{{ include "chart.server.matchLabels" . }}
{{ include "chart.common.metaLabels" . }}
{{- end -}}
# ------------------------------------ /LABELS ------------------------------- #




# ------------------------------------ ENVS ---------------------------------- #
{{- define "chart.server.greeter.env_" -}}
{{- range $key, $value := .Values.server.greeter.env }}
{{ $key }}: '{{ $value }}'
{{- end }}
{{- end -}}
# ------------------------------------ ENVS ---------------------------------- #




# ------------------------------------------ SA ------------------------------ #
{{/*
Create the name of the service account to use for the server component
*/}}
{{- define "chart.serviceAccountName.server" -}}
{{- if .Values.serviceAccounts.server.create -}}
    {{ default (include "chart.server.fullname" .) .Values.serviceAccounts.server.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccounts.server.name }}
{{- end -}}
{{- end -}}
# ------------------------------------------ SA ------------------------------ #
