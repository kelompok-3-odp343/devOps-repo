#!/bin/bash
set -e

# ==================================================
# 1️⃣ Update & Install Dependencies
# ==================================================
sudo apt-get update -y
sudo apt-get install -y curl

# ==================================================
# 2️⃣ Install K3s Master Node
# ==================================================
curl -sfL https://get.k3s.io | sh -s - server \
  --cluster-init \
  --node-name=wandoor-master \
  --node-external-ip=10.148.15.215 \
  --flannel-backend=vxlan

# Pastikan service aktif
sudo systemctl enable k3s
sudo systemctl start k3s

echo "=================================================="
echo "✅ K3s Master setup complete!"
echo "📍 Worker Token:"
sudo cat /var/lib/rancher/k3s/server/node-token
echo "=================================================="

# Tunggu beberapa detik agar kube-apiserver siap
sleep 10

# ==================================================
# 3️⃣ Install ArgoCD di Namespace 'argocd'
# ==================================================
echo "🚀 Installing ArgoCD..."

# Buat namespace argocd
sudo kubectl create namespace argocd || true

# Deploy ArgoCD menggunakan manifest resmi
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Tunggu semua pod ArgoCD siap (opsional)
echo "⏳ Menunggu ArgoCD pods siap..."
sudo kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd || true

# ==================================================
# 4️⃣ Ekspose ArgoCD via NodePort (biar bisa diakses dari luar)
# ==================================================
echo "🌐 Exposing ArgoCD Server via NodePort..."

sudo kubectl patch svc argocd-server -n argocd -p '{
  "spec": {
    "type": "NodePort",
    "ports": [
      {
        "port": 443,
        "targetPort": 8080,
        "nodePort": 30080
      }
    ]
  }
}'

echo "=================================================="
echo "✅ ArgoCD installed successfully!"
echo "🌍 Access via: https://10.148.15.215:30080"
echo "🔑 Initial admin password:"
sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""
echo "=================================================="
