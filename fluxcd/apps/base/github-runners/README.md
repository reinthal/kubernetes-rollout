# Configuring Github Runners

After creating the app and secret in github Apps, do this

https://github.com/settings/apps/palisaderesearch-github-runner

```bash
kubectl create secret generic controller-manager -n github-runners \
 --from-literal=github_app_id=1367534 \
 --from-literal=github_app_installation_id=69878035 \
 --from-literal=github_app_private_key="$PRIVATE_KEY" \
 --from-literal=github_pat="$GITHUBPAT" \
 -o yaml --dry-run=client | tee secrets.yaml | kubectl apply -f -
```



This will configure the secret which has to be done manually. Note that the namespace has to exist prior to running the above command.
