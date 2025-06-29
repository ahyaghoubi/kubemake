#!/bin/bash

# Kubemake Enhanced Setup Script
# This script prepares the control node for running kubemake with enhanced validation

set -e

echo "=========================================="
echo "       KUBEMAKE ENHANCED SETUP"
echo "=========================================="
echo ""
echo "This script will:"
echo "1. Install Ansible and required collections"
echo "2. Validate your system configuration"
echo "3. Prepare for enhanced deployment"
echo ""

# Check if running on a supported OS
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "❌ Error: This script is designed for Linux systems"
    echo "For Windows users, please use WSL2 or a Linux VM"
    exit 1
fi

# Check if we're on Ubuntu/Debian
if ! command -v apt &> /dev/null; then
    echo "❌ Error: This script requires apt package manager (Ubuntu/Debian)"
    exit 1
fi

echo "✅ Operating system compatibility confirmed"

# Update package lists
echo ""
echo "📦 Installing system dependencies..."
sudo apt update -qq

# Install Python and pip if not present
echo "Installing Python and development tools..."
sudo apt install -y python3 python3-pip python3-venv python3-dev build-essential curl git sshpass

# Check Python version
PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
echo "✅ Python version: $PYTHON_VERSION"

if ! python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3, 8) else 1)'; then
    echo "⚠️  Warning: Python 3.8+ is recommended for best compatibility"
fi

# Install pipx
echo ""
echo "📦 Installing pipx..."
sudo apt install -y pipx
pipx ensurepath

# Install Ansible using pipx
echo ""
echo "🔧 Installing Ansible with pipx..."

# Install Ansible with dependencies using pipx
echo "Installing Ansible and required Python packages with pipx..."
pipx install --include-deps ansible

# Install additional Python dependencies for Kubernetes
echo "Installing additional Python dependencies..."
pipx inject ansible kubernetes PyYAML requests

echo "✅ Ansible and Python packages installed with pipx"

# Ensure pipx PATH is available in current session
export PATH="$HOME/.local/bin:$PATH"

# Source bashrc to ensure PATH is updated
echo "🔄 Updating PATH environment..."
source ~/.bashrc 2>/dev/null || true

# Verify Ansible installation
echo ""
echo "🔍 Verifying Ansible installation..."
if ! command -v ansible-playbook &> /dev/null; then
    echo "❌ Error: Ansible installation failed"
    echo "Please run: source ~/.bashrc"
    echo "Then verify with: ansible --version"
    exit 1
fi

echo "✅ Ansible installed successfully: $(ansible --version | head -n1)"

# Install required Ansible collections
echo ""
echo "📚 Installing required Ansible collections..."
if [ -f "requirements.yml" ]; then
    ansible-galaxy collection install -r requirements.yml
    echo "✅ Ansible collections installed"
else
    echo "❌ Error: requirements.yml not found"
    exit 1
fi

# Validate playbook syntax
echo ""
echo "🔍 Validating playbook syntax..."
for playbook in site.yml site-improved.yml; do
    if [ -f "$playbook" ]; then
        if ansible-playbook "$playbook" --syntax-check &> /dev/null; then
            echo "✅ $playbook syntax valid"
        else
            echo "❌ $playbook syntax validation failed"
            exit 1
        fi
    fi
done

# Check if inventory exists
echo ""
echo "📋 Checking inventory configuration..."
if [ -f "hosts" ]; then
    echo "✅ Inventory file 'hosts' found"
    
    # Run variable validation
    if [ -f "check-vars.sh" ]; then
        chmod +x check-vars.sh
        echo "Running variable validation..."
        if ./check-vars.sh; then
            echo "✅ All required variables are configured"
        else
            echo "⚠️  Some variables may be missing - check your inventory"
        fi
    fi
else
    echo "⚠️  No 'hosts' inventory file found"
    echo "Please copy and customize 'hosts.example' to 'hosts'"
fi

echo ""
echo "=========================================="
echo "           SETUP COMPLETE! 🎉"
echo "=========================================="
echo ""
echo "✅ Ansible and dependencies installed with pipx"
echo "✅ Required collections configured"
echo "✅ Playbook syntax validated"
echo ""
echo "🚀 READY FOR DEPLOYMENT!"
echo ""
echo "Next steps:"
echo ""
echo "1. Ensure your inventory is configured:"
echo "   - Copy 'hosts.example' to 'hosts' if not already done"
echo "   - Update with your server IP addresses and credentials"
echo ""
echo "2. Run pre-deployment validation:"
echo "   chmod +x pre-check.sh && ./pre-check.sh"
echo ""
echo "3. Deploy kubemake with ENHANCED validation (RECOMMENDED):"
echo "   ansible-playbook site-improved.yml -i hosts"
echo ""
echo "   OR deploy with basic playbook:"
echo "   ansible-playbook site.yml -i hosts"
echo ""
echo "4. For selective deployment:"
echo "   # Just Kubernetes cluster:"
echo "   ansible-playbook site-improved.yml -i hosts --tags setup,init"
echo ""
echo "   # Add service mesh:"
echo "   ansible-playbook site-improved.yml -i hosts --tags mesh,telemetry"
echo ""
echo "   # Add chaos engineering:"
echo "   ansible-playbook site-improved.yml -i hosts --tags chaos"
echo ""
echo "📚 Documentation:"
echo "   - README.md: Full documentation"
echo "   - TROUBLESHOOTING.md: Common issues and solutions"
echo "   - DEPLOYMENT_READY.md: Deployment checklist"
echo ""
echo "🔍 Need help? Run the pre-check script first:"
echo "   ./pre-check.sh"
