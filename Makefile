# Makefile for Observability TP - Terraform + Ansible
# Usage: make <target>

.PHONY: help init plan apply wait-ssh provision all destroy clean

# Default target
help:
	@echo "🚀 Observability TP - Available targets:"
	@echo ""
	@echo "  init       - Initialize Terraform and set up environment"
	@echo "  plan       - Plan Terraform deployment"
	@echo "  apply      - Apply Terraform configuration"
	@echo "  wait-ssh   - Wait for SSH connectivity to all VMs"
	@echo "  provision  - Run Ansible playbook to configure VMs"
	@echo "  all        - Complete deployment (init → plan → apply → wait-ssh → provision)"
	@echo "  destroy    - Destroy all infrastructure"
	@echo "  clean      - Clean up temporary files"
	@echo "  outputs    - Show Terraform outputs"
	@echo "  check      - Check SSH connectivity"
	@echo ""
	@echo "📋 Prerequisites:"
	@echo "  1. Set GOOGLE_APPLICATION_CREDENTIALS environment variable"
	@echo "  2. Copy terraform/terraform.tfvars.example to terraform/terraform.tfvars"
	@echo "  3. Edit terraform/terraform.tfvars with your values"
	@echo ""

# Initialize Terraform
init:
	@echo "🔧 Initializing Terraform..."
	@if [ ! -f "terraform/terraform.tfvars" ]; then \
		echo "❌ Error: terraform/terraform.tfvars not found"; \
		echo "Please copy terraform/terraform.tfvars.example to terraform/terraform.tfvars and edit it"; \
		exit 1; \
	fi
	@if [ -z "$$GOOGLE_APPLICATION_CREDENTIALS" ]; then \
		echo "❌ Error: GOOGLE_APPLICATION_CREDENTIALS environment variable not set"; \
		echo "Please set it to the path of your GCP service account JSON key"; \
		exit 1; \
	fi
	terraform -chdir=terraform init

# Plan Terraform deployment
plan: init
	@echo "📋 Planning Terraform deployment..."
	terraform -chdir=terraform plan

# Apply Terraform configuration
apply: init
	@echo "🚀 Applying Terraform configuration..."
	terraform -chdir=terraform apply -auto-approve
	@echo "✅ Infrastructure deployed successfully!"

# Wait for SSH connectivity
wait-ssh:
	@echo "⏳ Waiting for SSH connectivity..."
	@bash scripts/check-ssh.sh

# Run Ansible playbook
provision: wait-ssh
	@echo "🎭 Running Ansible playbook..."
	@if [ ! -f "ansible/inventory/inventory.ini" ]; then \
		echo "❌ Error: Ansible inventory not found"; \
		echo "Make sure Terraform has been applied successfully"; \
		exit 1; \
	fi
	ansible-playbook -i ansible/inventory/inventory.ini ansible/site.yml
	@echo "✅ Configuration completed successfully!"

# Complete deployment
all: init plan apply wait-ssh provision
	@echo "🎉 Complete deployment finished!"
	@echo ""
	@echo "🌐 Access URLs:"
	@terraform -chdir=terraform output -raw app_url 2>/dev/null | sed 's/^/  App: /'
	@terraform -chdir=terraform output -raw zabbix_url 2>/dev/null | sed 's/^/  Zabbix: /'
	@terraform -chdir=terraform output -raw grafana_url 2>/dev/null | sed 's/^/  Grafana: /'
	@echo ""
	@echo "🔑 Default credentials:"
	@echo "  Zabbix: Admin / zabbix"
	@echo "  Grafana: admin / admin"
	@echo ""
	@echo "⚠️  Please change default passwords!"

# Destroy infrastructure
destroy:
	@echo "🗑️ Destroying infrastructure..."
	@read -p "Are you sure you want to destroy all infrastructure? (yes/no): " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		terraform -chdir=terraform destroy -auto-approve; \
		echo "✅ Infrastructure destroyed successfully!"; \
	else \
		echo "❌ Destruction cancelled"; \
	fi

# Show Terraform outputs
outputs:
	@echo "📊 Terraform outputs:"
	@bash scripts/export-tf-outputs.sh

# Check SSH connectivity
check:
	@echo "🔍 Checking SSH connectivity..."
	@bash scripts/check-ssh.sh

# Clean up temporary files
clean:
	@echo "🧹 Cleaning up temporary files..."
	@rm -f ansible/inventory/inventory.ini
	@rm -f terraform/.terraform.lock.hcl
	@rm -rf terraform/.terraform/
	@echo "✅ Cleanup completed!"
