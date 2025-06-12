#!/bin/bash

# Comprehensive Kubemake Pre-Deployment Check (Enhanced)
echo "=========================================="
echo "   KUBEMAKE PRE-DEPLOYMENT VALIDATION"
echo "=========================================="
echo ""
echo "This script validates your system before kubemake deployment"
echo "Recommended deployment: ansible-playbook site-improved.yml -i hosts"
echo ""

ERRORS=0
WARNINGS=0

# Function to report errors
error() {
    echo "❌ ERROR: $1"
    ERRORS=$((ERRORS + 1))
}

# Function to report success
success() {
    echo "✅ $1"
}

# Function to report warnings
warning() {
    echo "⚠️  WARNING: $1"
    WARNINGS=$((WARNINGS + 1))
}

echo ""
echo "1. CHECKING INVENTORY FILE..."
echo "--------------------------------------------"

if [ ! -f "hosts" ]; then
    error "Inventory file 'hosts' not found"
else
    success "Inventory file found"
    
    # Check for required sections
    if grep -q "^\[masters\]" hosts; then
        success "Masters section found"
    else
        error "Masters section missing in inventory"
    fi
    
    if grep -q "^\[workers\]" hosts; then
        success "Workers section found"
    else
        warning "Workers section missing (OK for single-node setup)"
    fi
    
    # Check for required variables
    required_vars=("kubernetes_version" "kubernetes_major_version" "crio_version" "crio_os" "apiserver_advertise_address")
    for var in "${required_vars[@]}"; do
        if grep -q "$var" hosts; then
            success "$var defined"
        else
            error "$var not defined in inventory"
        fi
    done
fi

echo ""
echo "2. CHECKING ANSIBLE REQUIREMENTS..."
echo "--------------------------------------------"

# Check for Ansible in PATH and pipx locations
ANSIBLE_FOUND=false
if command -v ansible-playbook &> /dev/null; then
    success "Ansible found: $(ansible --version | head -n1)"
    ANSIBLE_FOUND=true
elif [ -x "$HOME/.local/bin/ansible-playbook" ]; then
    success "Ansible found in pipx: $($HOME/.local/bin/ansible --version | head -n1)"
    ANSIBLE_FOUND=true
    # Update PATH for this session
    export PATH="$HOME/.local/bin:$PATH"
elif [ -x "/root/.local/bin/ansible-playbook" ]; then
    success "Ansible found in pipx: $(/root/.local/bin/ansible --version | head -n1)"
    ANSIBLE_FOUND=true
    # Update PATH for this session
    export PATH="/root/.local/bin:$PATH"
fi

if [ "$ANSIBLE_FOUND" = false ]; then
    error "Ansible not found. Please install Ansible first."
fi

if [ -f "requirements.yml" ]; then
    success "Requirements file found"
else
    error "requirements.yml not found"
fi

echo ""
echo "3. CHECKING PLAYBOOK SYNTAX..."
echo "--------------------------------------------"

# Only check syntax if Ansible was found
if [ "$ANSIBLE_FOUND" = true ]; then
    for playbook in site.yml site-improved.yml; do
        if [ -f "$playbook" ]; then
            if ansible-playbook "$playbook" --syntax-check &> /dev/null; then
                success "$playbook syntax valid"
            else
                error "$playbook syntax validation failed"
            fi
        fi
    done
else
    error "Cannot validate playbook syntax - Ansible not available"
fi

echo ""
echo "4. CHECKING ROLE STRUCTURE..."
echo "--------------------------------------------"

required_roles=("common" "crio" "k8s/common" "k8s/init" "flannel" "istio")
for role in "${required_roles[@]}"; do
    if [ -f "roles/$role/tasks/main.yml" ]; then
        success "Role $role found"
    else
        error "Role $role missing or incomplete"
    fi
done

echo ""
echo "5. CHECKING NETWORK CONNECTIVITY..."
echo "--------------------------------------------"

if [ -f "hosts" ]; then
    # Extract master IP from inventory
    master_ip=$(grep "ansible_host=" hosts | head -n1 | sed 's/.*ansible_host=\([0-9.]*\).*/\1/')
    
    if [ ! -z "$master_ip" ]; then
        echo "Testing connectivity to master: $master_ip"
        if ping -c 1 "$master_ip" &> /dev/null; then
            success "Master node $master_ip is reachable"
        else
            warning "Cannot ping master node $master_ip (may be expected if ICMP is blocked)"
        fi
    fi
fi

echo ""
echo "=========================================="
echo "        VALIDATION SUMMARY"
echo "=========================================="

if [ $ERRORS -eq 0 ]; then
    echo "🎉 ALL CRITICAL CHECKS PASSED!"
    if [ $WARNINGS -gt 0 ]; then
        echo "⚠️  $WARNINGS warning(s) found (non-critical)"
    fi
    echo ""
    echo "🚀 RECOMMENDED DEPLOYMENT:"
    echo "   ansible-playbook site-improved.yml -i hosts"
    echo ""
    echo "Alternative deployments:"
    echo "   ansible-playbook site.yml -i hosts"
    echo ""
    echo "Selective deployment examples:"
    echo "   # Just Kubernetes cluster:"
    echo "   ansible-playbook site-improved.yml -i hosts --tags setup,init"
    echo ""
    echo "   # Add service mesh later:"
    echo "   ansible-playbook site-improved.yml -i hosts --tags mesh,telemetry"
    echo ""
    exit 0
else
    echo "❌ $ERRORS CRITICAL ERROR(S) FOUND!"
    if [ $WARNINGS -gt 0 ]; then
        echo "⚠️  $WARNINGS warning(s) also found"
    fi
    echo ""
    echo "Please fix the critical errors above before deploying."
    echo "Check TROUBLESHOOTING.md for solutions."
    echo ""
    exit 1
fi
