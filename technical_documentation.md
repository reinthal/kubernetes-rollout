# Kubernetes Infrastructure Technical Documentation

## Project Overview
This document details the technical implementation of our Kubernetes infrastructure built on Talos OS using Sidero Omni, provisioned on Hetzner Cloud.

## Infrastructure Components

### 1. Cloud Provider
- **Provider**: Hetzner Cloud
- **Region**: EU Central (Frankfurt)
- **Infrastructure**: 3 VPS instances

### 2. Kubernetes Setup
- **Operating System**: Talos OS via Sidero Omni
- **Kubernetes Version**: Latest stable
- **Node Distribution**:
  - 1 Control Plane Node
  - 2 Worker Nodes

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

resource "hcloud_network_subnet" "omni_subnet" {
  network_id   = hcloud_network.omni_network.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}
```

### Talos OS Configuration
Talos OS is deployed using a custom Omni Image snapshot in Hetzner Cloud. The image was created with Packer to ensure consistency and repeatability.

## Network Security

### Tailscale Integration
All nodes are securely connected using Tailscale for encrypted networking:
- Provides private networking between all nodes
- Enables secure SSH access to nodes
- Integrates with Kubernetes for secure access to the cluster

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

FluxCD is bootstrapped to connect to our GitHub repository:

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

### Dev Environment Configuration
Developer dependencies are managed using devenv.nix:

```nix
packages = with pkgs; [ 
  git 
  terraform
  packer
  sops
  age
  kubeconform
  tailscale
  omnictl
  fluxcd
  hcloud
  kubectl
  krew
  kubelogin-oidc
  kubernetes-helm
  talosctl
  k9s
  jq
  curl
];
```

## Current Status and Known Issues

### Completed
- Basic infrastructure provisioning with Terraform
- Kubernetes cluster creation with Talos OS
- Initial FluxCD setup for GitOps

### In Progress
- Developer box provisioning
- Complete FluxCD configuration
- HAP-CTF application deployment

### Known Issues
1. OIDC Login Plugin configuration in devenv.nix needs fixing
2. Hetzner CSI provider has compatibility issues with Talos OS
3. Developer box storage provisioning needs further investigation

## Next Steps
1. Resolve storage provisioning issues for developer boxes
2. Complete the OIDC authentication configuration
3. Finish FluxCD setup for complete GitOps workflow
4. Deploy the HAP-CTF application
5. Implement monitoring with Prometheus and Grafana 