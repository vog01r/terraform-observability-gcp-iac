#!/bin/bash
# Script to check SSH connectivity to all VMs

set -e

echo "🔍 Checking SSH connectivity to all VMs..."

# Get IPs from Terraform outputs
APP_IP=$(terraform -chdir=terraform output -raw app_ip 2>/dev/null || echo "")
ZABBIX_IP=$(terraform -chdir=terraform output -raw zabbix_ip 2>/dev/null || echo "")
GRAFANA_IP=$(terraform -chdir=terraform output -raw grafana_ip 2>/dev/null || echo "")
SSH_USER=$(terraform -chdir=terraform output -raw ssh_user 2>/dev/null || echo "ubuntu")

if [ -z "$APP_IP" ] || [ -z "$ZABBIX_IP" ] || [ -z "$GRAFANA_IP" ]; then
    echo "❌ Error: Could not get IP addresses from Terraform outputs"
    echo "Make sure Terraform has been applied successfully"
    exit 1
fi

echo "📋 VM IPs:"
echo "  App: $APP_IP"
echo "  Zabbix: $ZABBIX_IP"
echo "  Grafana: $GRAFANA_IP"
echo "  SSH User: $SSH_USER"
echo

# Function to check SSH connectivity
check_ssh() {
    local hostname=$1
    local ip=$2
    local max_attempts=30
    local attempt=1
    
    echo "🔌 Checking SSH connectivity to $hostname ($ip)..."
    
    while [ $attempt -le $max_attempts ]; do
        if ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o BatchMode=yes $SSH_USER@$ip "echo 'SSH connection successful'" >/dev/null 2>&1; then
            echo "✅ $hostname is reachable via SSH"
            return 0
        fi
        
        echo "⏳ Attempt $attempt/$max_attempts - Waiting for $hostname..."
        sleep 10
        ((attempt++))
    done
    
    echo "❌ Failed to connect to $hostname after $max_attempts attempts"
    return 1
}

# Check all VMs
failed=0

check_ssh "App VM" "$APP_IP" || failed=1
check_ssh "Zabbix VM" "$ZABBIX_IP" || failed=1
check_ssh "Grafana VM" "$GRAFANA_IP" || failed=1

if [ $failed -eq 0 ]; then
    echo
    echo "🎉 All VMs are reachable via SSH!"
    echo "✅ Ready to run Ansible playbook"
else
    echo
    echo "❌ Some VMs are not reachable via SSH"
    echo "Please check the VM status and network connectivity"
    exit 1
fi
