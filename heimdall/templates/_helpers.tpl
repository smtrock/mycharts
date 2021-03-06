apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: {{ template "heimdall.fullname" . }}
  labels:
    app: {{ template "heimdall.name" . }}
    chart: {{ template "heimdall.chart" . }}
    release: {{ .Release.Name }}
    heritage: {{ .Release.Service }}
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  revisionHistoryLimit: 1
  replicas: 1
  template:
    metadata:
      labels:
        app: {{ template "heimdall.name" . }}
        release: {{ .Release.Name }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          env:
            - name: TZ
              value: "EST5EDT"
          ports:
            - name: heimdall
              containerPort: 80
              protocol: TCP
          volumeMounts:
            - mountPath: /config
              name: config
          resources:
{{ toYaml .Values.resources | indent 12 }}
    {{- with .Values.nodeSelector }}
      nodeSelector:
{{ toYaml . | indent 8 }}
    {{- end }}
    {{- with .Values.affinity }}
      affinity:
{{ toYaml . | indent 8 }}
    {{- end }}
    {{- with .Values.tolerations }}
      tolerations:
{{ toYaml . | indent 8 }}
    {{- end }}
      volumes:
        - hostPath:
            path: /data/config/heimdall
            type: DirectoryOrCreate
          name: config