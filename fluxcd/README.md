# How to bootstrap

```
flux check --pre
```

then

```
flux bootstrap github \
    --context=reinthal-talos-default \
    --owner=${GITHUB_USER} \
    --repository=${GITHUB_REPO} \
    --branch=main \
    --personal \
    --path=fluxcd/clusters/production
```
