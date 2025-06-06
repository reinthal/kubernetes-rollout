# Secrets Directory

This directory contains encrypted secrets and configuration files used during development and deployment.

## Files

### `config.env`
Environment variables for development and deployment, encrypted with SOPS:
- `TF_VAR_hetzner_api_key` - Hetzner Cloud API key for Terraform
- `TF_VAR_tailscale_authkey` - Tailscale authentication key
- `HCLOUD_TOKEN` - Hetzner Cloud token for CLI operations
- `GITHUB_USER` - GitHub username for GitOps
- `GITHUB_REPO` - GitHub repository name
- `GITHUB_TOKEN` - GitHub personal access token

This file is sourced during development to provide necessary API keys and tokens.

## Usage

To decrypt and source the environment variables:
```bash
sops -d config.env > .env.local
source .env.local
```

## Security

All secrets are encrypted using SOPS with Age encryption. The decryption key is managed separately and should not be committed to the repository. 