#!/bin/bash
# Starts (resumes) all k0s project VMs.

set -e # Exit immediately if a command exits with a non-zero status.

# Source the helper functions from the setup directory
source "$(dirname "$0")/../setup/scripts/lib/helpers.sh"

echo_info "Finding project VMs to start..."
VMS_TO_START=$(get_vm_list)

if [[ -z "$VMS_TO_START" ]]; then
  echo_warn "No project VMs found to start."
  exit 0
fi

for vm in $VMS_TO_START; do
  echo "  -> Starting '$vm'..."
  multipass start "$vm"
done

echo_success "All project VMs have been started."