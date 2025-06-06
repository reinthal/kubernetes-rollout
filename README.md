# Kubernetes Infrastructure on Talos OS

A Kubernetes infrastructure deployment built on Talos OS using Sidero Omni, provisioned on Hetzner Cloud with GitOps using FluxCD.

## Project Overview

This project implements a production-ready Kubernetes cluster with the following components:
- **Cloud Provider**: Hetzner Cloud (EU Central - Frankfurt)
- **Operating System**: Talos OS
- **Infrastructure**: 3 VPS instances (1 control plane, 3 workers)
- **GitOps**: FluxCD for continuous delivery
- **Development**: Nix-based development environment
- **

## Architecture

### Infrastructure Components

**Kubernetes Cluster**
- 1 Control Plane Node
- 3 Worker Nodes
- Latest stable Kubernetes version

**Development Environment**
- Nix-based dependency management
- Automated environment setup with direnv/devenv
- All necessary tools pre-configured

## Infrastructure as Code

### Terraform Configuration

The infrastructure is provisioned using Terraform with the following key components:

```hcl
# Server provisioning
resource "hcloud_server" "omni_nodes" {
  count       = 3
  name        = "omni-node-${count.index + 1}"
  server_type = var.server_type
  image       = var.snapshot_id
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.default.id]
  
  labels = {
    role = count.index == 0 ? "control-plane" : "worker"
  }
}

# Network configuration
resource "hcloud_network" "omni_network" {
  name     = "omni-network"
  ip_range = "10.0.0.0/16"
}
```

### Talos OS Configuration

Talos OS is deployed using a custom Omni Image snapshot in Hetzner Cloud. The image was created with Packer to ensure consistency and repeatability.

## Continuous Delivery

### FluxCD Setup

GitOps implementation using FluxCD with the following structure:

```
fluxcd/
├── apps/           # Application deployments
├── clusters/       # Cluster-specific configuration
├── helm-values/    # Helm chart values
├── infrastructure/ # Infrastructure components
└── scripts/        # Utility scripts
```

FluxCD is bootstrapped to connect to the GitHub repository:

```bash
flux bootstrap github \
    --context=talos-default \
    --owner=${GITHUB_USER} \
    --repository=${GITHUB_REPO} \
    --branch=main \
    --personal \
    --path=fluxcd/clusters/production
```

## Development Environment

### Prerequisites

- Nix package manager
- direnv

### Setup

1. Clone the repository
2. Enter the directory (direnv will automatically load the environment)
3. Run `direnv reload` to set up the shell environment

### Available Tools

The development environment includes:
- `terraform` - Infrastructure provisioning
- `kubectl` - Kubernetes CLI
- `talosctl` - Talos OS CLI
- `omnictl` - Sidero Omni CLI
- `flux` - FluxCD CLI
- `hcloud` - Hetzner Cloud CLI
- `k9s` - Kubernetes dashboard
- `sops` - Secrets management

## Directory Structure

- `terraform/` - Infrastructure as Code configurations
- `fluxcd/` - GitOps configurations and Kubernetes manifests
- `nix-container/` - Container build configurations
- `secrets/` - Encrypted secrets and configuration
- `.github/` - CI/CD workflows

## Current Status

### Completed
- Basic infrastructure provisioning with Terraform
- Kubernetes cluster creation with Talos OS
- Initial FluxCD setup for GitOps
- Tailscale integration for secure networking

### Known Issues
1. Hetzner CSI provider has compatibility issues with Talos OS
2. Developer box storage provisioning needs further investigation

## Planned Features

1. Deploy HAP-CTF HTTP API with HPA autoscaling
2. Provision developer boxes with Tailscale SSH access
3. Implement monitoring with Prometheus and Grafana
4. Configure automated alerts for critical system metrics
5. Set up backup strategy for critical components
