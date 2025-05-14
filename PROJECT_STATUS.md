# Kubernetes Rollout Project - Status Update

## Current Progress

This project aims to set up a Kubernetes infrastructure on Talos OS using Sidero Omni with developer boxes and application deployment capabilities. Below is the current progress:

### ✅ Completed Tasks

1. **Account Setup**
   - Sidero Omni account configured
   - Tailscale account created and configured

2. **Infrastructure Provisioning**
   - Terraform scripts created for Hetzner Cloud
   - 3 Omni nodes provisioned (1 control plane, 2 workers)
   - Network configuration with proper subnets

3. **Kubernetes Setup**
   - Kubernetes cluster created with Talos OS
   - Basic authentication configured
   - Initial kubectl access established

4. **Continuous Delivery**
   - FluxCD initialized for GitOps approach
   - Repository structure set up for infrastructure configuration
   - Bootstrap process configured

### 🚧 In Progress Tasks

1. **Developer Box Setup**
   - Experiencing issues with Hetzner CSI provider compatibility with Talos OS
   - Storage provisioning for developer environments needs resolution

2. **Authentication Configuration**
   - OIDC login plugin in devenv.nix requires fixing
   - Access to Kubernetes cluster needs streamlining

3. **Application Deployment**
   - HAP-CTF HTTP API deployment not yet started
   - Cloudflared exposure pending

### ❌ Not Started Tasks

1. **Monitoring Setup**
   - Prometheus and Grafana installation
   - Alert configuration
   - Backup strategy

## Known Issues and Challenges

1. **Storage Integration**: The Hetzner CSI provider has compatibility issues with Talos OS, making it challenging to provision persistent storage for developer boxes.

2. **Authentication Flow**: The OIDC login plugin configuration in devenv.nix is causing issues with Kubernetes authentication.

3. **GitOps Integration**: The full GitOps workflow with FluxCD requires additional configuration for Terraform and Tailscale integration.

## Next Steps

1. Resolve the CSI provider issues to enable proper storage provisioning
2. Fix the OIDC authentication configuration
3. Complete the FluxCD setup for full GitOps workflow
4. Begin application deployment once infrastructure issues are resolved

## File Structure

```
.
├── terraform/              # Infrastructure as Code
│   ├── main.tf             # Main Terraform configuration
│   ├── variables.tf        # Variable definitions
│   └── omni/               # Omni-specific configurations
├── fluxcd/                 # GitOps configuration
│   ├── clusters/           # Cluster-specific settings
│   ├── infrastructure/     # Infrastructure components
│   └── apps/               # Application deployments
└── devenv.nix              # Development environment configuration
```

## How to Use This Repository

1. Clone the repository
2. Set up the required accounts (Hetzner, Omni, Tailscale)
3. Configure the necessary environment variables
4. Run Terraform to provision the infrastructure
5. Use the FluxCD bootstrap command to initialize GitOps 