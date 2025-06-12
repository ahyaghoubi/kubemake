# Kubemake Troubleshooting Guide

## Common Issues and Solutions

### 1. Kubernetes Repository Issues

**Problem**: `apt update` fails with Kubernetes repository errors
**Solution**: The old `apt.kubernetes.io` repository has been deprecated. This version of kubemake uses the new `pkgs.k8s.io` repository.

**Symptoms**:
- GPG key errors
- Repository not found errors
- Package not available errors

**Fix**: Ensure you're using the updated version of kubemake with the new repository configuration.

### 2. CRI-O Installation Failures

**Problem**: CRI-O fails to install or start
**Solutions**:
- Verify the `crio_version` matches your Kubernetes version
- Check that `crio_os` matches your Ubuntu version (e.g., `xUbuntu_22.04` for Ubuntu 22.04)
- Ensure system has enough resources (minimum 2GB RAM, 2 CPUs)

### 3. Flannel Network Issues

**Problem**: Pods cannot communicate across nodes
**Solutions**:
- Check that the `flannel_iface_regex` matches your network interface names
- Verify the `pod_network_cidr` doesn't conflict with your host network
- Ensure all nodes can reach each other on the specified interfaces

### 4. Istio Installation Issues

**Problem**: Istio components fail to start
**Solutions**:
- Verify Kubernetes cluster is healthy before installing Istio
- Check that all nodes have sufficient resources
- Ensure the Istio version is compatible with your Kubernetes version

### 5. Python/Ansible Dependencies

**Problem**: Ansible modules fail with import errors
**Solutions**:
- Install the kubernetes Python package instead of the deprecated openshift package
- Run: `pip3 install kubernetes>=24.2.0`
- Install required Ansible collections: `ansible-galaxy collection install -r requirements.yml`

## Pre-installation Checklist

Before running kubemake, ensure:

1. **System Requirements**:
   - Ubuntu 20.04, 22.04, or 24.04
   - Minimum 2GB RAM per node
   - Minimum 2 CPU cores per node
   - 20GB free disk space

2. **Network Requirements**:
   - All nodes can communicate with each other
   - Internet access for package downloads
   - Unique hostnames for each node

3. **Access Requirements**:
   - SSH access from control node to all cluster nodes
   - Sudo privileges on all cluster nodes
   - SSH key-based authentication recommended

4. **Variables Configuration**:
   - Update inventory file with correct node IPs
   - Set appropriate versions for your environment
   - Configure network settings for your infrastructure

## Debugging Commands

### Check Kubernetes cluster status:
```bash
kubectl get nodes
kubectl get pods --all-namespaces
kubectl cluster-info
```

### Check CRI-O status:
```bash
sudo systemctl status crio
sudo crictl info
sudo crictl ps
```

### Check container runtime:
```bash
kubectl get nodes -o wide
sudo crictl version
```

### Check network connectivity:
```bash
kubectl get pods -n kube-flannel
kubectl logs -n kube-flannel -l app=flannel
```

## Getting Help

If you continue to experience issues:

1. Check the Ansible output for specific error messages
2. Verify your inventory file configuration
3. Ensure all prerequisites are met
4. Check system logs: `journalctl -u kubelet` or `journalctl -u crio`
