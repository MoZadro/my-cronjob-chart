{{/*
	Private docker registry helper 
*/}}
{{- define "imagePullSecret" }}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .Values.imageCredentials.registry (printf "%s:%s" .Values.imageCredentials.username .Values.imageCredentials.password | b64enc) | b64enc }}
{{- end }}

{{- define "checkdnsHost" }}
{{- if regexMatch ".*[.].*" .Values.ingress.dnsHost }}
{{- fail "value for .Values.ingress.dnsHost is not as expected. It should be only application name, without any dots." }}
{{- else -}}
{{- printf .Values.ingress.dnsHost }}
{{- end -}}
{{- end }}


{{- define "createDns" -}}
{{- if .Values.ingress.host -}}
{{- printf .Values.ingress.host }}
{{- else -}}
{{- template "checkdnsHost" .  -}}
{{- if eq .Values.cluster "staging-ubercluster" -}}
{{- printf ".%s.%s.%s" "staging" "de-3" "nsoft.cloud" }}
{{- else if eq .Values.cluster "ubercluster" -}}
{{- printf ".%s.%s" "de-3" "nsoft.cloud" }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "dockerSecretName" -}}
{{- if eq .Values.teamName "int" -}}
{{- printf "docker-bot-integrations" }}
{{- else if eq .Values.teamName "svn" -}}
{{- printf "docker-bot-seven" }}
{{- else if eq .Values.teamName "ngs" -}}
{{- printf "docker-bot-games" }}
{{- else if eq .Values.teamName "cas" -}}
{{- printf "docker-bot-casino" }}
{{- else if eq .Values.teamName "god" -}}
{{- printf "docker-bot-godfather" }}
{{- else if eq .Values.teamName "test" -}}
{{- printf "docker-bot-godfather" }}
{{- else if eq .Values.teamName "tof" -}}
{{- printf "docker-bot-tof" }}
{{- end -}}
{{- end -}}

{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "tof-helm-cronjob-template.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "tof-helm-cronjob-template.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "tof-helm-cronjob-template.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "tof-helm-cronjob-template.labels" -}}
helm.sh/chart: {{ include "tof-helm-cronjob-template.chart" . }}
{{ include "tof-helm-cronjob-template.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "tof-helm-cronjob-template.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tof-helm-cronjob-template.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "tof-helm-cronjob-template.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "tof-helm-cronjob-template.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}


{{/*
Helpers for Env variable with Helm, custom Helper
*/}}
{{- define "helpers.list-env-variables"}}
{{- range $key, $val := .Values.envSecret }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Release.Name }}-env-secret
      key: {{ $key }}
{{- end}}
{{- end }}