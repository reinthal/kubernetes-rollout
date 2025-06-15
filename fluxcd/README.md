# How to bootstrap

## Prerequisites

0. **Apply the github runner secret**

   ```
    kubectl create ns github-runners && \
    kubectl create secret generic controller-manager -n github-runners \
      --from-literal=github_app_id=1367534 \
      --from-literal=github_app_installation_id=69878035 \
      --from-literal=github_app_private_key="$PRIVATE_KEY" \
      --from-literal=github_pat="$GITHUB_PAT" \
      -o yaml --dry-run=client | tee secrets.yaml | kubectl apply -f -
   ```
1. **Apply Hetzner Cloud Secrets**: First, apply the required secrets for Hetzner CCM:

   ```bash
   kubectl apply -f infrastructure/controllers/hcloud-token.yaml
   kubectl apply -f infrastructure/controllers/hcloud-token-kube-system.yaml
   ```
2. **Apply cloudflare secret**: Then Cloudflare Api Token

   ```
   kubectl apply -f infrastructure/configs/cloudflare-api-token-secret.yaml
   ```

2. **Update Hetzner CCM Configuration**: Before bootstrapping FluxCD, you MUST update the server IDs in `infrastructure/controllers/hcloud-ccm.yaml` with your actual Hetzner Cloud server IDs.

   ```bash
   # Get your server IDs after Terraform deployment
   hcloud server list
   
   # Update the providerID fields in hcloud-ccm.yaml:
   # - Replace the server IDs with your actual ones
   # - Update for: talos-controlplane, talos-worker-1, talos-worker-2, talos-worker-3
   ```

3. **Check FluxCD prerequisites**:
   ```bash
   flux check --pre
   ```

## Bootstrap Command

```bash
flux bootstrap github \
    --context='admin@talos-hcloud-cluster' \
    --owner=${GITHUB_USER} \
    --repository=${GITHUB_REPO} \
    --branch=main \
    --personal \
    --path=fluxcd/clusters/production
```

## Important Notes

- The CCM requires proper node provider IDs to manage load balancer targets correctly
- Without correct provider IDs, load balancers may show "No targets" and return empty responses
- Commit the updated server IDs to git before running the bootstrap command
