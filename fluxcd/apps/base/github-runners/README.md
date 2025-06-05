# Configuring Github Runners

After creating the app and secret in github Apps, do this

https://github.com/settings/apps/palisaderesearch-github-runner

```bash
kubectl create secret generic controller-manager -n github-runners \
 --from-literal=github_app_id=1367534 \
 --from-literal=github_app_installation_id=Iv23liPDyqkW90fVoZSA \
 --from-literal=github_app_private_key=YOUR_PRIVATE_KEY \
 -o yaml --dry-run=client | tee secrets.yaml | kubectl apply -f -
```



This will configure the secret which has to be done manually. Note that the namespace has to exist prior to running the above command.
