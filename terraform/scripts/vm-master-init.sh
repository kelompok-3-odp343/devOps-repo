#!/bin/bash
set -e

echo "===== [1] Update system ====="
apt update -y
apt upgrade -y

echo "===== [2] Install dependencies ====="
apt install -y python3 python3-pip python3-venv git openssh-client google-cloud-cli

echo "===== [3] Install Ansible ====="
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

echo "===== [7] Generate SSH Key ====="
sudo -u adamalhafizh23 ssh-keygen -t rsa -b 4096 -N "" -f /home/adamalhafizh23/.ssh/id_rsa

PUBKEY=$(cat /home/adamalhafizh23/.ssh/id_rsa.pub)

echo "===== [8] Register SSH key to ALL instances ====="
ZONE="asia-southeast1-b"

for VM in wandoor-master wandoor-db wandoor-monitoring wandoor-worker-1; do
  echo ">>> Adding SSH key to $VM ..."
  gcloud compute instances add-metadata $VM \
    --zone $ZONE \
    --metadata "ssh-keys=adamalhafizh23:${PUBKEY} adamalhafizh23@wandoor-master"
done

echo "===== [9] Clone infra repo ====="
mkdir -p /home
sudo git clone -b production https://github.com/kelompok-3-odp343/infra.git /home/infra
chown -R adamalhafizh23:adamalhafizh23 /home/infra
chmod +x /home/infra/terraform/generate_inventory.sh
/home/infra/terraform/generate_inventory.sh

echo "===== SSH key added to all instances ====="
echo "===== MASTER READY ====="
