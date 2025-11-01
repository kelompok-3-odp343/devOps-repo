#!/bin/bash
set -e

echo "===== VM1: Starting setup for App Server ====="

# Update system
sudo apt-get update -y && sudo apt-get upgrade -y

# Install dependencies
sudo apt-get install -y curl git

# Install Docker
echo "Installing Docker..."
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Install K3s as server (lightweight Kubernetes)
echo "Installing K3s (Server)..."
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644" sh -

# Wait until K3s is ready
echo "Waiting for K3s to be ready..."
sleep 30

# Clone your app repo (ubah URL repo jika perlu)
echo "Cloning application repository..."
cd /home/$USER
git clone https://github.com/<your-username>/<your-app-repo>.git app

# Build and run app container (contoh Node.js)
cd app
sudo docker build -t wandoor-app .
sudo docker run -d -p 80:80 --name wandoor-app wandoor-app

echo "===== VM1: Setup completed successfully! ====="
