#!/bin/bash
set -eo pipefail

source "$(dirname "$0")/lib/helpers.sh"
source "$(dirname "$0")/../values.env"

# Determine k0s version
if [[ -z "$K0S_VERSION" ]]; then
  echo_info "Fetching latest k0s version from GitHub..."
  # Using jq is more robust for parsing JSON than grep/cut
  K0S_VERSION_FETCHED=$(curl -s https://api.github.com/repos/k0sproject/k0s/releases/latest | jq -r .tag_name)
  if [[ -z "$K0S_VERSION_FETCHED" || "$K0S_VERSION_FETCHED" == "null" ]]; then
    echo_error "Failed to fetch k0s version. Exiting."
    exit 1
  fi
else
  K0S_VERSION_FETCHED=$K0S_VERSION
fi
echo_info "Using k0s version: $K0S_VERSION_FETCHED"

# Create the output directory if it doesn't exist
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Generate the main part of the config
cat <<EOF > "$OUTPUT_FILE"
apiVersion: k0sctl.k0sproject.io/v1beta1
kind: Cluster
metadata:
  name: multipass-k0s
spec:
  k0s:
    version: $K0S_VERSION_FETCHED
    config:
      spec:
        network:
          provider: calico
  hosts:
EOF

echo_info "Generating k0sctl.yaml configuration..."
multipass list --format csv | tail -n +2 | while IFS=',' read -r name state ip _; do
  [[ "$state" != "Running" ]] && continue

  if [[ "$name" == *"k0s-controller"* ]]; then
    role="controller+worker"
  elif [[ "$name" == *"k0s-worker"* ]]; then
    role="worker"
  else
    continue
  fi

  cat <<EOF >> "$OUTPUT_FILE"
    - role: $role
      ssh:
        address: $ip
        user: ubuntu
        keyPath: $SSH_KEY_PATH
EOF
done

echo_success "Generated k0sctl configuration at $OUTPUT_FILE"