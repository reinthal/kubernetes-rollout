# Kubernetes Infrastructure on Talos OS

A Kubernetes infrastructure deployment built on Talos OS using Sidero Omni, provisioned on Hetzner Cloud with GitOps using FluxCD.

## Project Overview

This project implements a production-ready Kubernetes cluster with the following components:
- **Cloud Provider**: Hetzner Cloud
- **Operating System**: Talos OS
- **Infrastructure**: 3 VPS instances (1 control plane, 3 workers)
- **GitOps**: FluxCD for continuous delivery
- **Development**: Nix-based development environment

In Kubernetes we have

- **OpenEbs**: Persistent storage with OpenEbs
- **Github Actions**: Action Runner Controller and one RunnerDeployment using custom image pre-bundled nix dependencies.

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

The infrastructure is provisioned using the following command:


Up:

```
echo yes | terraform apply -var-file="workers.tfvars"
```

Down:

```
echo yes | terraform destroy -var-file="workers.tfvars"
```

Current worker config:

```
workers = {
  1 = {
    server_type = "cpx51",
    name        = "talos-worker-1",
    location    = "nbg1",
    ip          = "10.0.0.4",
    labels      = { "type" : "talos-worker" },
    taints      = [],
  },
  2 = {
    server_type = "cpx51",
    name        = "talos-worker-2",
    location    = "nbg1",
    ip          = "10.0.0.5",
    labels      = { "type" : "talos-worker" },
    taints      = [],
  },
  3 = {
    server_type = "cpx51",
    name        = "talos-worker-3",
    location    = "nbg1",
    ip          = "10.0.0.6",
    labels      = { "type" : "talos-worker" },
    taints      = [],
  }
}

```


### Talos OS Configuration

Talos OS is deployed using a custom image snapshot in Hetzner Cloud. The image was created with Packer as described in the Talos guidelines.

## Continuous Delivery

### FluxCD Setup

GitOps implementation using FluxCD with the following structure:

```
fluxcd/
├── apps/           # Application deployments
├── clusters/       # Cluster-specific configuration
├── helm-values/    # Helm chart values for reference reading
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

- Github Action Runner + Controller
- Persistent storage with OpenEbs
- Basic infrastructure provisioning with Terraform
- Kubernetes cluster creation with Talos OS
- Initial FluxCD setup for GitOps

### Known Issues

## Planned Features

0. Developer box storage provisioning needs further investigation
1. Deploy HAP-CTF HTTP API with HPA autoscaling
2. Provision developer boxes with Tailscale SSH access
3. Implement monitoring with Prometheus and Grafana
4. Configure automated alerts for critical system metrics
5. Set up backup strategy for critical components
