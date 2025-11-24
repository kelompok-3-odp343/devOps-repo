# devOps-repo
# MONITORING
Repositori ini berisi seluruh konfigurasi dan panduan untuk membangun sistem Monitoring, Logging, dan Tracing pada environment Kubernetes + VM.

Stack ini terdiri dari:
- Prometheus – Metrics collection
- Node Exporter – Metrics node VM & Kubernetes
- cAdvisor – Metrics container
- kube-state-metrics – Metrics state Kubernetes
- Loki – Log aggregation
- Promtail – Log collector dari Kubernetes
- Tempo – Distributed tracing backend
- Grafana – Visualization dashboard
- OTel Collector (on Cluster) – Pipeline traces dari Kubernetes → Tempo

Setup pada VM Monitoring:
1. masuk ke direktori docker-compose
2. jalankan perintah "docker compose up -d"
3. pastikan semua container running saat jalankan perintah "docker ps"

Setup pada VM Master:
1. Install Node Exporter (DaemonSet) dengan perintah "kubectl apply -f node-exporter-daemonset.yaml"
2. Install cAdvisor (DaemonSet) dengan perintah "kubectl apply -f cadvisor-daemonset.yaml"
3. Install kube-state-metrics (Deployment + Service + RBAC) dengan perintah "kubectl apply -f kube-state-metrics.yaml" dan "kubectl apply -f rbac/kube-state-metrics-rbac.yaml"
4. Install Promtail (Logs → Loki) dengan perintah "kubectl apply -f promtail-daemonset.yaml"
5. Install OTel Collector (Traces → Tempo) dengan perintah "kubectl apply -f otel-daemonset.yaml"

