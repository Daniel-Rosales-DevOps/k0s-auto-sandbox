# Makefile for managing the k0s automated setup.

# ------------------------------------------------------------------------------
#  Variable Definitions
# ------------------------------------------------------------------------------
# Using SHELL to ensure bash is used, for consistency.
SHELL := /bin/bash

# ------------------------------------------------------------------------------
#  Target Definitions
# ------------------------------------------------------------------------------
# Use .PHONY to declare targets that are not actual files.
# This prevents conflicts if a file with the same name as a target exists.
.PHONY: all help tools setup delete

# The default target that runs when you just type "make".
all: help

# A self-documenting help target.
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available targets:"
	@echo "  help      Show this help message."
	@echo "  setup     Provision VMs and set up the k0s cluster."
	@echo "  stop      Stop all running VMs without deleting them."
	@echo "  start     Start all stopped VMs, necessary after a stop or reboot."
	@echo "  tools     Install all required tools for the cluster (kubectl, k0sctl, multipass)."
	@echo "  delete    Delete all VMs and clean up the cluster."
	@echo "  exec      Make all scripts executable, necessary for setting up the cluster."

# Target to install prerequisite tools.
tools:
	@echo "--> Installing prerequisite tools..."
	@(cd k0s-auto-setup/tools-install && ./k0sctl-install.sh && ./kubectl-install.sh && ./multipass-install.sh)

# Target to create the entire cluster.
setup:
	@echo "--> Starting cluster setup..."
	@(cd k0s-auto-setup/setup && ./create-cluster.sh)

# Target to delete the entire cluster.
delete:
	@echo "--> Deleting cluster and all associated VMs..."
	@(cd k0s-auto-setup/delete-cluster && ./delete-cluster.sh)

# Target to stop all running VMs without deleting them.
stop:
	@echo "--> Stopping all running VMs..."
	@(cd k0s-auto-setup/manage && ./stop-vms.sh)

# Target to start all stopped VMs.
start:
	@echo "--> Starting all stopped VMs..."
	@(cd k0s-auto-setup/manage && ./start-vms.sh)

# Target to make all scripts executable.
# This is useful for ensuring that all shell scripts can be executed.
exec:
	@echo "--> Making all scripts executable..."
	@find . -name "*.sh" -exec chmod +x {} \;