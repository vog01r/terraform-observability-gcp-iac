#!/bin/bash
# Script to export Terraform outputs for debugging

set -e

echo "📊 Exporting Terraform outputs..."

cd terraform

if [ ! -f "terraform.tfstate" ]; then
    echo "❌ Error: No Terraform state file found"
    echo "Run 'terraform apply' first"
    exit 1
fi

echo "🔍 Current Terraform outputs:"
echo "================================"

terraform output -json | jq -r '
  "App VM:",
  "  Private IP: " + .app_ip.value,
  "  Public IP: " + .app_public_ip.value,
  "",
  "Zabbix VM:",
  "  Private IP: " + .zabbix_ip.value,
  "  Public IP: " + .zabbix_public_ip.value,
  "",
  "Grafana VM:",
  "  Private IP: " + .grafana_ip.value,
  "  Public IP: " + .grafana_public_ip.value,
  "",
  "URLs:",
  "  App: " + .app_url.value,
  "  Zabbix: " + .zabbix_url.value,
  "  Grafana: " + .grafana_url.value,
  "",
  "SSH User: " + .ssh_user.value,
  "Inventory Path: " + .inventory_path.value
'

echo
echo "📋 Environment variables for manual testing:"
echo "export APP_IP=$(terraform output -raw app_ip)"
echo "export ZABBIX_IP=$(terraform output -raw zabbix_ip)"
echo "export GRAFANA_IP=$(terraform output -raw grafana_ip)"
echo "export SSH_USER=$(terraform output -raw ssh_user)"
echo
echo "🌐 Quick access URLs:"
echo "App: $(terraform output -raw app_url)"
echo "Zabbix: $(terraform output -raw zabbix_url)"
echo "Grafana: $(terraform output -raw grafana_url)"
