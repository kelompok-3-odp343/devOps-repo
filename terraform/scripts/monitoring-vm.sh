#!/bin/bash
set -e

echo "=== Update & install Docker ==="
sudo apt update -y
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Install Docker
if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  sudo systemctl enable docker
  sudo systemctl start docker
fi

# Install Docker Compose
if ! command -v docker-compose &> /dev/null; then
  sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
fi

echo "=== Membuat direktori monitoring ==="
mkdir -p ~/monitoring/{prometheus,loki,tempo,grafana}

# --- prometheus.yml ---
cat <<EOF > ~/monitoring/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'kubernetes-nodes'
    static_configs:
      - targets: ['10.148.15.215:9100', '10.148.15.216:9100', '10.148.15.217:9100']
        labels:
          role: node

  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
EOF

# --- tempo-config.yml ---
cat <<EOF > ~/monitoring/tempo/tempo-config.yml
server:
  http_listen_port: 3200

distributor:
  receivers:
    otlp:
      protocols:
        http:
        grpc:

storage:
  trace:
    backend: local
    local:
      path: /tmp/tempo/traces
EOF

# --- docker-compose.yml ---
cat <<EOF > ~/monitoring/docker-compose.yml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus
    container_name: prometheus
    restart: always
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml

  loki:
    image: grafana/loki:2.9.0
    container_name: loki
    restart: always
    ports:
      - "3100:3100"
    command: -config.file=/etc/loki/local-config.yaml

  tempo:
    image: grafana/tempo:2.4.1
    container_name: tempo
    restart: always
    ports:
      - "3200:3200"
      - "4320:4317"
      - "4321:4318"
    volumes:
      - ./tempo/tempo-config.yml:/etc/tempo/tempo.yml
    command: -config.file=/etc/tempo/tempo.yml

  grafana:
    image: grafana/grafana:10.0.3
    container_name: grafana
    restart: always
    ports:
      - "3000:3000"
    volumes:
      - grafana-storage:/var/lib/grafana

volumes:
  grafana-storage:
EOF

echo "=== Menjalankan Docker Compose ==="
cd ~/monitoring
sudo docker-compose up -d

echo "=== Setup selesai! ==="
echo "Prometheus -> http://<vm-monitoring-ip>:9090"
echo "Loki -> http://<vm-monitoring-ip>:3100"
echo "Tempo -> http://<vm-monitoring-ip>:3200"
echo "Grafana -> http://<vm-monitoring-ip>:3000 (user: admin / pass: admin)"
