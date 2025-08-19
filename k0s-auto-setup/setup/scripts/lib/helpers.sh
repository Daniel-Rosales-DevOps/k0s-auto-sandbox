#!/bin/bash

# A library of shared functions for the k0s setup scripts.

# --- Color Codes for Logging ---
# Usage: echo_info "This is an informational message."
# Usage: echo_success "Something worked!"
# Usage: echo_warn "warning for something!"
# Usage: echo_error "Something failed!"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo_info() {
  echo -e "${BLUE}INFO: $1${NC}"
}

echo_success() {
  echo -e "${GREEN}SUCCESS: $1${NC}"
}

echo_warn() {
  echo -e "${YELLOW}WARN: $1${NC}"
}

echo_error() {
  echo -e "${RED}ERROR: $1${NC}"
}


# --- VM Utility Functions ---

# Gets a space-separated list of all k0s VM names
get_vm_list() {
  multipass list --format csv | tail -n +2 | grep 'k0s-' | cut -d',' -f1 | tr '\n' ' '
}

# Gets a space-separated list of all k0s VM IPs
get_vm_ips() {
  multipass list --format csv | tail -n +2 | grep 'k0s-' | cut -d',' -f3 | tr '\n' ' '
}

# Waits for a VM to be ready for an SSH connection
# Usage: wait_for_ssh "k0s-controller-1"
wait_for_ssh() {
    local vm_name=$1
    echo_info "Waiting for SSH on $vm_name..."
    until multipass exec "$vm_name" -- timeout 2 bash -c "true" &>/dev/null; do
        sleep 2
    done
    echo_success "SSH is ready on $vm_name."
}
