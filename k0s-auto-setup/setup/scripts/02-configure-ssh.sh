#!/bin/bash
set -eo pipefail

source "$(dirname "$0")/lib/helpers.sh"
source "$(dirname "$0")/../values.env"

# Resolve the tilde to an absolute path
key_path_expanded="${SSH_KEY_PATH/#\~/$HOME}"

# Check for SSH key and generate if missing
if [[ ! -f "$key_path_expanded" ]]; then
  echo_info "SSH key not found at $key_path_expanded. Creating one..."
  ssh-keygen -t rsa -b 4096 -f "$key_path_expanded" -N "" # Generate a new key without a passphrase
else
  echo_info "SSH key already exists."
fi

echo_info "Waiting for VMs to be ready for SSH..."
# This is a more robust wait than a simple 'sleep'
for vm in $(get_vm_list); do
  wait_for_ssh "$vm"
done

PUBKEY=$(cat "${key_path_expanded}.pub")
echo_info "Injecting public SSH key into all VMs..."
for vm in $(get_vm_list); do
  echo "  -> Injecting into $vm..."
  multipass exec "$vm" -- bash -c "mkdir -p ~/.ssh && echo \"$PUBKEY\" >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"
done

echo_info "Clearing old known_hosts entries..."
for ip in $(get_vm_ips); do
    ssh-keygen -R "$ip" 2>/dev/null || true
done

echo_success "SSH configuration complete."