#!/bin/bash

# Kubemake Validation Script
# This script validates all playbooks and configurations before deployment

set -e

echo "=== Kubemake Validation Script ==="

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if Ansible is installed
if ! command_exists ansible-playbook; then
    echo "❌ Error: Ansible not found. Please run setup.sh first."
    exit 1
fi

echo "✅ Ansible found: $(ansible --version | head -n1)"

# Check if required collections are installed
echo "Checking required Ansible collections..."
if ansible-galaxy collection list kubernetes.core &> /dev/null; then
    echo "✅ kubernetes.core collection found"
else
    echo "❌ kubernetes.core collection not found"
    exit 1
fi

# Validate main playbook syntax
echo "Validating site.yml syntax..."
if ansible-playbook site.yml --syntax-check &> /dev/null; then
    echo "✅ site.yml syntax is valid"
else
    echo "❌ site.yml syntax validation failed"
    ansible-playbook site.yml --syntax-check
    exit 1
fi

# Validate improved playbook syntax
if [ -f "site-improved.yml" ]; then
    echo "Validating site-improved.yml syntax..."
    if ansible-playbook site-improved.yml --syntax-check &> /dev/null; then
        echo "✅ site-improved.yml syntax is valid"
    else
        echo "❌ site-improved.yml syntax validation failed"
        ansible-playbook site-improved.yml --syntax-check
        exit 1
    fi
fi

# Check if inventory example exists
if [ -f "hosts.example" ]; then
    echo "✅ hosts.example found"
else
    echo "❌ hosts.example not found"
    exit 1
fi

# Validate requirements.yml
if [ -f "requirements.yml" ]; then
    echo "✅ requirements.yml found"
    if ansible-galaxy collection install -r requirements.yml --dry-run &> /dev/null; then
        echo "✅ requirements.yml is valid"
    else
        echo "⚠️  Warning: requirements.yml validation failed"
    fi
else
    echo "❌ requirements.yml not found"
    exit 1
fi

# Check role structure
echo "Checking role structure..."
required_roles=("common" "crio" "k8s/common" "k8s/init" "k8s/join" "flannel" "istio" "istio/addons" "chaos-mesh")

for role in "${required_roles[@]}"; do
    if [ -f "roles/$role/tasks/main.yml" ]; then
        echo "✅ Role $role found"
    else
        echo "❌ Role $role missing"
        exit 1
    fi
done

echo ""
echo "=== Validation Complete ==="
echo "✅ All checks passed! Kubemake is ready for deployment."
echo ""
echo "Next steps:"
echo "1. Copy hosts.example to your own inventory file"
echo "2. Update the inventory with your server details"
echo "3. Run: ansible-playbook site.yml -i your-inventory-file"
