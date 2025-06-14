# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Kubernetes infrastructure deployment project using Talos OS on Hetzner Cloud with GitOps via FluxCD. The architecture consists of a control plane node and 3 worker nodes, managed through Infrastructure as Code.

## Common Commands

### Infrastructure Management
- **Deploy infrastructure**: `echo yes | terraform apply -var-file="workers.tfvars"`
- **Destroy infrastructure**: `echo yes | terraform destroy -var-file="workers.tfvars"`
- **Validate FluxCD manifests**: `./fluxcd/validate.sh`

### FluxCD Bootstrap
```bash
flux bootstrap github \
    --context=talos-default \
    --owner=${GITHUB_USER} \
    --repository=${GITHUB_REPO} \
    --branch=main \
    --personal \
    --path=fluxcd/clusters/production
```

### Development Environment
- Environment is managed via Nix/devenv - all tools are pre-configured
- Run `direnv reload` to setup shell environment
- Available tools: terraform, kubectl, talosctl, omnictl, flux, hcloud, k9s, sops

## Architecture & Structure

### Key Components
- **terraform/**: Infrastructure provisioning with Hetzner Cloud provider
- **fluxcd/**: GitOps configuration split into apps, clusters, infrastructure, and helm-values
- **nix-container/**: Custom container builds (GitHub Actions runners with Nix)
- **secrets/**: SOPS-encrypted configuration files

### Infrastructure Pattern
- Uses Hetzner Cloud with private networking (10.0.0.0/24)
- Control plane behind load balancer for HA
- Workers get extra SSD volumes for storage
- Custom Talos OS image built with Packer

### FluxCD Organization
```
fluxcd/
├── apps/           # Application deployments (per environment)
├── clusters/       # Environment-specific flux configuration
├── helm-values/    # External Helm values files
└── infrastructure/ # Platform components (controllers, configs)
```

## Important Conventions

### HelmRelease & Values Files
When working with FluxCD HelmRelease resources, always check for corresponding values files in `fluxcd/helm-values/`. Key relationships:
- HelmRelease resources reference external values files for complex configurations
- Common values files: `actions-runner-controller.yaml`, `openebs-csi.yaml`, `hcloud-csi.yaml`, `tailscale-operator-values.yaml`
- Ensure consistency between inline values and external values files
- Prefer external values files over large inline values sections

### Secret Management
- Secrets are managed with SOPS encryption in the `secrets/` directory
- Never commit unencrypted secrets
- Use age encryption keys for SOPS operations

### Validation
- Always run `./fluxcd/validate.sh` before committing FluxCD changes
- Script validates YAML syntax and Kubernetes resource schemas using kubeconform
- Skips Secret validation due to SOPS encrypted fields