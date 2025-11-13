#!/bin/bash
set -e

# -------------------------
# Config
# -------------------------
DEFAULT_ANSIBLE_USER="ubuntu"

INVENTORY_DIR="../ansible/inventory"
INVENTORY_PATH="$INVENTORY_DIR/inventory.ini"
INVENTORY_JSON="$INVENTORY_DIR/inventory.json"

mkdir -p "$INVENTORY_DIR"

# -------------------------
# Ambil output Terraform
# -------------------------
echo "📥 Mengambil data IP dari Terraform..."
terraform output -json vm_ips > "$INVENTORY_JSON"

# -------------------------
# Ambil semua IP dari JSON
# -------------------------
MASTER_PUBLIC=$(jq -r '.master.public_ip // empty' "$INVENTORY_JSON")
MASTER_PRIVATE=$(jq -r '.master.private_ip // empty' "$INVENTORY_JSON")

DB_PUBLIC=$(jq -r '.db.public_ip // empty' "$INVENTORY_JSON")
DB_PRIVATE=$(jq -r '.db.private_ip // empty' "$INVENTORY_JSON")

WORKER1_PUBLIC=$(jq -r '.worker_1.public_ip // empty' "$INVENTORY_JSON")
WORKER1_PRIVATE=$(jq -r '.worker_1.private_ip // empty' "$INVENTORY_JSON")

WORKER2_PUBLIC=$(jq -r '.worker_2.public_ip // empty' "$INVENTORY_JSON")
WORKER2_PRIVATE=$(jq -r '.worker_2.private_ip // empty' "$INVENTORY_JSON")

MONITORING_PUBLIC=$(jq -r '.monitoring.public_ip // empty' "$INVENTORY_JSON")
MONITORING_PRIVATE=$(jq -r '.monitoring.private_ip // empty' "$INVENTORY_JSON")

# -------------------------
# Tulis inventory.ini tanpa private key
# -------------------------
cat > "$INVENTORY_PATH" <<EOF
# Generated automatically by generate_inventory.sh
# Default ansible user: $DEFAULT_ANSIBLE_USER
# Jalankan dengan: ansible-playbook -i inventory.ini <playbook>.yml

[master]
master ansible_host=${MASTER_PUBLIC:-} ansible_user=${DEFAULT_ANSIBLE_USER} private_ip=${MASTER_PRIVATE:-}

[db]
db ansible_host=${DB_PUBLIC:-} ansible_user=${DEFAULT_ANSIBLE_USER} private_ip=${DB_PRIVATE:-}

[worker]
worker1 ansible_host=${WORKER1_PUBLIC:-} ansible_user=${DEFAULT_ANSIBLE_USER} private_ip=${WORKER1_PRIVATE:-}
worker2 ansible_host=${WORKER2_PUBLIC:-} ansible_user=${DEFAULT_ANSIBLE_USER} private_ip=${WORKER2_PRIVATE:-}

[monitoring]
monitoring ansible_host=${MONITORING_PUBLIC:-} ansible_user=${DEFAULT_ANSIBLE_USER} private_ip=${MONITORING_PRIVATE:-}
EOF

echo "✅ Inventory file generated at: $INVENTORY_PATH"
echo ""
cat "$INVENTORY_PATH"
