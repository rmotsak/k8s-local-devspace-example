{{- define "vote-app.name" -}}
{{ .Chart.Name }}
{{- end -}}

{{- define "vote-app.fullname" -}}
{{ include "vote-app.name" . }}-{{ .Release.Name }}
{{- end -}}
