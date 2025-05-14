{ pkgs, lib, config, inputs, ... }:

{
  env.GREET = "devenv";
  

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


}
