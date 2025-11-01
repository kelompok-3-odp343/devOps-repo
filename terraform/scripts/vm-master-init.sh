#!/bin/bash
set -e

echo "🚀 Installing K3s (master node)..."
curl -sfL https://get.k3s.io | sh -

echo "📂 Saving kubeconfig for local kubectl access..."
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config

echo "🔐 Master node setup done!"
