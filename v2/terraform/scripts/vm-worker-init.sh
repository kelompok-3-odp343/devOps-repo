#!/bin/bash
set -e

# Update dan install dependency dasar
sudo apt-get update -y
sudo apt-get install -y curl

# Buat direktori konfigurasi K3s
sudo mkdir -p /etc/rancher/k3s

# Buat file konfigurasi untuk K3s agent
sudo tee /etc/rancher/k3s/config.yaml > /dev/null <<EOF
server: https://10.148.15.215:6443
token: K10a89678a91b9372f099f065e47a58cc4d163cdb44a8095834d9cf1dd0f3b457f7::server:96bbc93c634bea5c42a0d612efb7001e
EOF

# Jalankan agent K3s (worker)
curl -sfL https://get.k3s.io | K3S_URL="https://10.148.15.215:6443" \
K3S_TOKEN="K10a89678a91b9372f099f065e47a58cc4d163cdb44a8095834d9cf1dd0f3b457f7::server:96bbc93c634bea5c42a0d612efb7001e" \
sh -s - agent

# Pastikan service berjalan
sudo systemctl enable k3s-agent
sudo systemctl start k3s-agent

echo "✅ K3s Worker setup complete!"
