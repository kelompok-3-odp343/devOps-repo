#!/bin/bash

# --- Konfigurasi Awal ---
MINIKUBE_VERSION="latest" # Anda bisa menentukan versi tertentu
KUBECTL_VERSION="latest" # Menggunakan versi stabil terbaru

echo "🚀 Memulai instalasi Minikube dan Kubectl..."

# --- 1. Update Sistem dan Instal Dependensi ---
echo "⚙ Mengupdate sistem dan menginstal dependensi (curl, apt-transport-https)..."
sudo apt update -y
sudo apt install -y curl apt-transport-https

# --- 2. Instal Docker (Driver yang Direkomendasikan untuk VM GCP) ---
echo "🐳 Menginstal Docker..."
# Tambahkan kunci GPG resmi Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Tambahkan repositori Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instal paket Docker
sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Aktifkan dan mulai layanan Docker
sudo systemctl enable docker
sudo systemctl start docker

# Berikan izin untuk grup 'docker' kepada user saat ini (agar tidak perlu 'sudo' saat menggunakan Docker)
# Ini adalah bagian PENTING agar Minikube dapat dijalankan tanpa sudo oleh user saat ini.
# Untuk user lain, mereka perlu ditambahkan ke grup 'docker' secara manual jika mereka ingin menjalankan Minikube.
CURRENT_USER=$(whoami)
echo "👥 Menambahkan user saat ini ($CURRENT_USER) ke grup 'docker'..."
sudo usermod -aG docker $CURRENT_USER
# Catatan: User perlu LOGOUT dan LOGIN kembali agar perubahan grup ini berlaku.
echo "⚠ PERHATIAN: User saat ini ($CURRENT_USER) harus LOGOUT dan LOGIN kembali agar perubahan grup 'docker' berlaku!"


# --- 3. Instal Minikube ---
echo "📦 Mendownload dan menginstal Minikube..."
curl -Lo minikube https://storage.googleapis.com/minikube/releases/$MINIKUBE_VERSION/minikube-linux-amd64
sudo install minikube /usr/local/bin/minikube

# Hapus file yang didownload
rm minikube

# --- 4. Instal Kubectl (Alat Baris Perintah Kubernetes) ---
echo "📦 Mendownload dan menginstal Kubectl..."
# Download Kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Instal Kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Hapus file yang didownload
rm kubectl

# --- 5. Verifikasi Instalasi ---
echo "✅ Verifikasi Instalasi:"
minikube version
kubectl version --client

# --- 6. Contoh Penggunaan ---
echo "🎉 Instalasi selesai!"
echo "--------------------------------------------------------"
echo "✅ Untuk user saat ini ($CURRENT_USER): Silakan LOGOUT dan LOGIN kembali."
echo "   Setelah itu, Anda bisa menjalankan Minikube tanpa 'sudo'."
echo "   Contoh: minikube start --driver=docker"
echo "   Contoh: kubectl get nodes"
echo ""
echo "👥 Untuk user lain yang ingin menggunakan Minikube:"
echo "   Mereka juga harus ditambahkan ke grup 'docker' dan LOGOUT/LOGIN kembali."
echo "   Perintah: sudo usermod -aG docker <username_lain>"
echo "--------------------------------------------------------"