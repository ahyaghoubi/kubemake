#!/bin/bash

# Kubemake Installation Script
# This script prepares the control node for running kubemake

set -e

echo "=== Kubemake Setup Script ==="
echo "This script will install Ansible and required collections for kubemake"

# Check if running on a supported OS
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "Error: This script is designed for Linux systems"
    exit 1
fi

# Check if we're on Ubuntu/Debian
if ! command -v apt &> /dev/null; then
    echo "Error: This script requires apt package manager (Ubuntu/Debian)"
    exit 1
fi

# Update package lists
echo "Updating package lists..."
sudo apt update

# Install Python and pip if not present
echo "Installing Python and pip..."
sudo apt install -y python3 python3-pip python3-venv

# Check Python version
PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
echo "Python version: $PYTHON_VERSION"

if ! python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3, 8) else 1)'; then
    echo "Warning: Python 3.8+ is recommended for best compatibility"
fi

# Install Ansible
echo "Installing Ansible..."
pip3 install --user ansible>=6.0.0

# Add local bin to PATH if not already there
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    export PATH="$HOME/.local/bin:$PATH"
fi

# Verify Ansible installation
if ! command -v ansible-playbook &> /dev/null; then
    echo "Error: Ansible installation failed or PATH not updated"
    echo "Please run: source ~/.bashrc"
    echo "Then verify with: ansible --version"
    exit 1
fi

# Install required Ansible collections
echo "Installing required Ansible collections..."
ansible-galaxy collection install -r requirements.yml

echo "=== Setup Complete ==="
echo "Ansible version: $(ansible --version | head -n1)"
echo ""
echo "Please ensure you have:"
echo "1. SSH access to all cluster nodes"
echo "2. Sudo privileges on all cluster nodes"
echo "3. Updated the inventory file (hosts.example) with your node details"
echo ""
echo "To deploy kubemake:"
echo "  ansible-playbook site.yml -i your-inventory-file"
