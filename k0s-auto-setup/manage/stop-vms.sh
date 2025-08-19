#!/bin/bash
# Pauses all k0s project VMs.

set -e # Exit immediately if a command exits with a non-zero status.

# Source the helper functions from the setup directory
source "$(dirname "$0")/../setup/scripts/lib/helpers.sh"

echo_info "Finding project VMs to suspend..."
VMS_TO_SUSPEND=$(get_vm_list)

if [[ -z "$VMS_TO_SUSPEND" ]]; then
  echo_warn "No running project VMs found to suspend."
  exit 0
fi

for vm in $VMS_TO_SUSPEND; do
  echo "  -> Suspending '$vm'..."
  multipass suspend "$vm"
done

echo_success "All project VMs have been suspended."