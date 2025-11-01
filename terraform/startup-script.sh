#!/bin/bash
set -e
# Update system
apt-get update
apt-get upgrade -y
# Install required packages
apt-get install -y curl wget git
# Install K3s
curl -sfL https://get.k3s.io | sh -s - \
  --write-kubeconfig-mode 644 \
  --disable traefik \
  --node-name k3s-master
# Wait for K3s to be ready
sleep 30
# Setup kubectl for root and regular users
mkdir -p /root/.kube
cp /etc/rancher/k3s/k3s.yaml /root/.kube/config
chmod 600 /root/.kube/config
# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# Patch ArgoCD to use NodePort
kubectl patch svc argocd-server -n argocd -p '{"spec":{"type":"NodePort","ports":[{"port":443,"targetPort":8080,"nodePort":30443,"name":"https"}]}}'
# Wait for ArgoCD to be ready
sleep 60
# Get ArgoCD initial password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD Admin Password: $ARGOCD_PASSWORD" > /root/argocd-password.txt
echo "K3s and ArgoCD installation completed!"