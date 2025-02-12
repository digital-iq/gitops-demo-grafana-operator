{{- define "commonLabels" -}}
gitopsType: infra
{{- if .Values.commonLabels }}
{{ .Values.commonLabels | toYaml  }}
{{- end }}
{{- end }}

{{- define "commonAnnotations" -}}
argocd.argoproj.io/sync-options: Delete={{- .Values.deleteResources | default "false" }}
{{- if .Values.commonAnnotations }}
{{ .Values.commonAnnotations | toYaml }}
{{- end }}
{{- end }}
