#!/bin/bash

# Nama file inventory yang akan dihasilkan
OUTPUT_FILE="../ansible/inventory/inventory.ini"

# Hapus file lama jika ada
rm -f $OUTPUT_FILE

# Tambahkan header
cat <<EOF >> $OUTPUT_FILE
# Generated automatically by generate_inventory.sh
# Default ansible user: ubuntu
# Jalankan dengan: ansible-playbook -i inventory.ini site.yml

EOF

# ===== MASTER =====
echo "[master]" >> $OUTPUT_FILE
gcloud compute instances list --filter="name~'wandoor-master'" --format="value(networkInterfaces[0].networkIP)" | \
while read IP; do
  echo "master ansible_host=$IP ansible_user=ubuntu" >> $OUTPUT_FILE
done
echo "" >> $OUTPUT_FILE

# ===== DB =====
echo "[db]" >> $OUTPUT_FILE
gcloud compute instances list --filter="name~'wandoor-db'" --format="value(networkInterfaces[0].networkIP)" | \
while read IP; do
  echo "db ansible_host=$IP ansible_user=ubuntu" >> $OUTPUT_FILE
done
echo "" >> $OUTPUT_FILE

# ===== WORKER =====
echo "[worker]" >> $OUTPUT_FILE
gcloud compute instances list --filter="name~'wandoor-worker'" --format="value(networkInterfaces[0].networkIP,name)" | \
while read IP NAME; do
  echo "$NAME ansible_host=$IP ansible_user=ubuntu" >> $OUTPUT_FILE
done
echo "" >> $OUTPUT_FILE

# ===== MONITORING =====
echo "[monitoring]" >> $OUTPUT_FILE
gcloud compute instances list --filter="name~'wandoor-monitoring'" --format="value(networkInterfaces[0].networkIP)" | \
while read IP; do
  echo "monitoring ansible_host=$IP ansible_user=ubuntu" >> $OUTPUT_FILE
done
echo "" >> $OUTPUT_FILE

echo "✅ Inventory file berhasil dibuat: $OUTPUT_FILE"
