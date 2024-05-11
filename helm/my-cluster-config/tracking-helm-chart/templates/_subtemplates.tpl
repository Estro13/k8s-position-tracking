
{{- define "webAppImage"}}
- name: webapp
  image: {{ .Values.dockerRepoName | default "richardchesterwood" | lower }}/k8s-fleetman-webapp-angular:release2-arm64
{{- end }}