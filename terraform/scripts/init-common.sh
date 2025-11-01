#!/bin/bash
set -e

echo "🔧 Updating system packages..."
sudo apt update -y && sudo apt upgrade -y

echo "⚙️ Installing basic dependencies..."
sudo apt install -y curl wget git vim net-tools unzip ufw

echo "🧱 Setting timezone..."
sudo timedatectl set-timezone Asia/Jakarta

echo "✅ Basic setup complete!"
