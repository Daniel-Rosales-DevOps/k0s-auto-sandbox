#!/bin/bash

echo "are you sure you want to continue? (yes/no)"
read answer
answer=${answer,,} # Convert to lowercase

if [[ $answer == "yes" ]]; then
  echo "Deleting cluster | This can take several minutes | Please wait..."

  echo "Removing known SSH host keys..."
  IPS=$(multipass list --format csv | tail -n +2 | grep 'k0s-' | cut -d',' -f3 | tr '\n' ' ')
  for ip in $IPS; do
    ssh-keygen -R "$ip" 2>/dev/null || true
  done

  echo "Removing VMs..."
  multipass delete --all && multipass purge || echo "VM deletion failed!"

  rm -f ../k0s/k0sctl.yaml || true

  # --- REMOVE .bashrc ENTRY ---
  echo "Cleaning up .bashrc configuration..." # Remove KUBECONFIG entry from .bashrc
  CONFIG_LINE='export KUBECONFIG=~/.kube/k0s-config'
  BASHRC_FILE=~/.bashrc
  if grep -qF -- "$CONFIG_LINE" "$BASHRC_FILE"; then
    sed -i.bak "s|${CONFIG_LINE}||g" "$BASHRC_FILE"
    # Optional: Clean up empty lines left by sed
    sed -i.bak '/^$/d' "$BASHRC_FILE"
    echo "KUBECONFIG path removed from $BASHRC_FILE."
  else
    echo "KUBECONFIG path not found in $BASHRC_FILE. No changes needed."
  fi
  # --- END .bashrc CLEANUP ---

  echo "Deletion of entire cluster complete."
else
  echo "Deletion aborted by user."
fi