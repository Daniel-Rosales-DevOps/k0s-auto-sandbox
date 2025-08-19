#!/bin/bash
set -eo pipefail # Exit on error

# Source helper functions and environment variables
source "$(dirname "$0")/lib/helpers.sh"
source "$(dirname "$0")/../values.env"

echo_info "Launching $CONTROL_PLANE_COUNT control plane node(s)..."
for i in $(seq 1 $CONTROL_PLANE_COUNT); do
  if ! multipass info "k0s-controller-$i" &>/dev/null; then
    multipass launch --name "k0s-controller-$i" --cpus $CPUS --memory $MEM --disk $DISK $IMAGE
  else
    echo_warn "VM k0s-controller-$i already exists. Skipping."
  fi
done

echo_info "Launching $WORKER_COUNT worker node(s)..."
for i in $(seq 1 $WORKER_COUNT); do
  if ! multipass info "k0s-worker-$i" &>/dev/null; then
    multipass launch --name "k0s-worker-$i" --cpus $CPUS --memory $MEM --disk $DISK $IMAGE
  else
    echo_warn "VM k0s-worker-$i already exists. Skipping."
  fi
done

echo_success "VM provisioning step complete."