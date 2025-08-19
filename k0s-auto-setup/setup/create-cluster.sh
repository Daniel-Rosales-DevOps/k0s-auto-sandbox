#!/bin/bash
# Main orchestrator for creating the k0s cluster

# Exit immediately if a command exits with a non-zero status.
set -eo pipefail

# --- SCRIPT START ---
echo "Starting k0s cluster setup..."

# Execute each stage
./scripts/01-provision-vms.sh
./scripts/02-configure-ssh.sh
./scripts/03-generate-config.sh

k0sctl apply --config ../k0s/k0sctl.yaml

echo "All setup scripts completed successfully."

k0sctl kubeconfig --config ../k0s/k0sctl.yaml > ~/.kube/k0s-config
export KUBECONFIG=~/.kube/k0s-config
# Make it persistent across sessions
echo 'export KUBECONFIG=~/.kube/k0s-config' >> ~/.bashrc
echo "Setup is complete"
echo "You can now use kubectl commands with the k0s cluster."
echo "Try running: kubectl get nodes"

