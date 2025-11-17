#!/bin/bash
set -e

echo "===== [1] Update system ====="
apt update -y
apt upgrade -y

echo "===== [2] Install dependencies ====="
apt install -y python3 python3-pip python3-venv git openssh-client google-cloud-cli

echo "===== [3] Install Ansible (from APT, NOT pip) ====="
apt install -y ansible

echo "===== [4] Set timezone ====="
timedatectl set-timezone Asia/Jakarta

echo "===== [5] Prepare Ansible directory ====="
mkdir -p /home/adamalhafizh23/ansible
chown -R adamalhafizh23:adamalhafizh23 /home/adamalhafizh23/

echo "===== [6] Enable SSH Agent Forwarding ====="
mkdir -p /home/adamalhafizh23/.ssh
cat <<EOF > /home/adamalhafizh23/.ssh/config
Host *
    ForwardAgent yes
EOF
chmod 600 /home/adamalhafizh23/.ssh/config
chown adamalhafizh23:adamalhafizh23 /home/adamalhafizh23/.ssh/config

echo "===== [7] Generate SSH key ====="
sudo -u adamalhafizh23 ssh-keygen -t rsa -b 4096 -N "" -f /home/adamalhafizh23/.ssh/id_rsa

PUBKEY=$(cat /home/adamalhafizh23/.ssh/id_rsa.pub)

echo "===== [8] Register public key at PROJECT level ====="
echo "adamalhafizh23:$PUBKEY" > /tmp/sshkey.txt

PROJECT_ID=$(gcloud config get-value project)

gcloud compute project-info add-metadata \
  --metadata-from-file ssh-keys=/tmp/sshkey.txt \
  --project "$PROJECT_ID"

echo "===== [9] Clone infra repo ====="
mkdir -p /home
sudo git clone https://github.com/kelompok-3-odp343/infra.git /home/infra
chown -R adamalhafizh23:adamalhafizh23 /home/infra
sudo chmod +x /home/infra/terraform/generate_inventory.sh
/home/infra/terraform/generate_inventory.sh


echo "===== SSH key added for ALL instances in project ====="
echo "===== MASTER READY ====="
