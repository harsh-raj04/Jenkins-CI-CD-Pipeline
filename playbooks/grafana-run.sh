#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Running Grafana playbook..."
ansible-playbook -i "$SCRIPT_DIR/aws_hosts" "$SCRIPT_DIR/grafana.yaml" -vv

echo "Running Prometheus playbook..."
ansible-playbook -i "$SCRIPT_DIR/aws_hosts" "$SCRIPT_DIR/install-prometheus.yaml" -vv
