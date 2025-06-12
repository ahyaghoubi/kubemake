#!/bin/bash

# Variable validation script for kubemake
echo "=== Kubemake Variable Validation ==="

# Check if all required variables are present in inventory
inventory_file="hosts"

if [ ! -f "$inventory_file" ]; then
    echo "❌ Inventory file 'hosts' not found"
    exit 1
fi

echo "✅ Inventory file found"

# Required variables for kubemake
required_vars=(
    "kubernetes_version"
    "kubernetes_major_version" 
    "crio_version"
    "crio_os"
    "pod_network_cidr"
    "flannel_iface_regex"
    "istio_version"
    "istio_profile"
    "istio_ingress_domain"
    "chaos_mesh_version"
    "kubelet_node_ip"
    "apiserver_advertise_address"
)

echo "Checking required variables..."

missing_vars=()
for var in "${required_vars[@]}"; do
    if grep -q "$var" "$inventory_file"; then
        echo "✅ $var found"
    else
        echo "❌ $var missing"
        missing_vars+=("$var")
    fi
done

if [ ${#missing_vars[@]} -eq 0 ]; then
    echo ""
    echo "✅ All required variables are present!"
else
    echo ""
    echo "❌ Missing variables: ${missing_vars[*]}"
    exit 1
fi

echo ""
echo "=== Variable Validation Complete ==="
