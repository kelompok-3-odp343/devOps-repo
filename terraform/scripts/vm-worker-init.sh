#!/bin/bash
set -e

MASTER_IP="<MASTER_IP>"
TOKEN="<TOKEN>"

echo "🚀 Installing K3s (worker node)..."
curl -sfL https://get.k3s.io | K3S_URL="https://${MASTER_IP}:6443" K3S_TOKEN="${TOKEN}" sh -

echo "✅ Worker node joined the cluster!"
