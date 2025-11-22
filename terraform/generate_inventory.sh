#!/bin/bash
set -e

OUTPUT_FILE="/home/infra/ansible/inventory/inventory.ini"

echo "===== Generate Ansible Inventory From GCP Instances ====="

# Ambil semua VM dengan internal IP
# Format output: NAME INTERNAL_IP
VM_DATA=$(gcloud compute instances list --format="value(name,networkInterfaces[0].networkIP)")

# Helper function: ambil IP berdasarkan nama VM
get_ip() {
    echo "$VM_DATA" | awk -v name="$1" '$1 == name {print $2}'
}

MASTER_IP=$(get_ip "wandoor-master")
DB_IP=$(get_ip "wandoor-db")
MONITORING_IP=$(get_ip "wandoor-monitoring")
WORKER1_IP=$(get_ip "wandoor-worker-1")

echo "IP MASTER: $MASTER_IP"
echo "IP DB: $DB_IP"
echo "IP MONITORING: $MONITORING_IP"
echo "IP WORKER-1: $WORKER1_IP"

echo "===== Writing inventory.ini ====="

cat <<EOF > $OUTPUT_FILE
# Generated automatically by generate_inventory.sh
# Jalankan dengan: ansible-playbook -i inventory.ini site.yml

[master]
master ansible_host=$MASTER_IP ansible_user=adamalhafizh23

[db]
db ansible_host=$DB_IP ansible_user=adamalhafizh23

[worker]
wandoor-worker-1 ansible_host=$WORKER1_IP ansible_user=adamalhafizh23

[monitoring]
monitoring ansible_host=$MONITORING_IP ansible_user=adamalhafizh23

[all:vars]
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
ansible_python_interpreter=/usr/bin/python3
EOF

echo "===== Inventory generated: $OUTPUT_FILE ====="
