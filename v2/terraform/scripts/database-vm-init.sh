#!/bin/bash
set -e

echo "🚀 Starting setup for Oracle DB and Redis..."

# Update sistem dan install docker
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Tambahkan repository Docker resmi
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# Install Docker
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Pastikan Docker berjalan
sudo systemctl enable docker
sudo systemctl start docker

echo "✅ Docker installed and running."

# --- Setup Oracle Database Container ---
echo "⚙️ Setting up Oracle Database container..."

# Buat volume untuk data Oracle
sudo docker volume create oracle-data

# Jalankan Oracle Database container
sudo docker run -d \
  --name oracle-db \
  -p 1521:1521 \
  -p 5500:5500 \
  -e ORACLE_PASSWORD=root \
  -e ORACLE_DATABASE=wandoor_db \
  -e APP_USER=wandoor \
  -e APP_USER_PASSWORD=root \
  -v oracle-data:/opt/oracle/oradata \
  gvenzl/oracle-free:23-slim

echo "✅ Oracle Database container is running."

# --- Setup Redis Container ---
echo "⚙️ Setting up Redis container..."

# Buat volume untuk data Redis
sudo docker volume create redis-data

# Jalankan Redis container
sudo docker run -d \
  --name redis-server \
  -p 6379:6379 \
  -v redis-data:/data \
  redis:7.2-alpine \
  redis-server --requirepass "rediswandoor"

echo "✅ Redis container is running."

# --- Cek status container ---
echo "🔍 Checking running containers..."
sudo docker ps

echo "=================================================="
echo "✅ Oracle DB & Redis setup completed successfully!"
echo "Oracle DB -> port 1521, user: wandoor, pass: root"
echo "Redis -> port 6379, password: rediswandoor"
echo "=================================================="
