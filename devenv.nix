{ pkgs, lib, config, inputs, ... }:

{
  env.GREET = "devenv";
  

  packages = with pkgs; [ 
    git 
    terraform
    packer
    sops
    age
    tailscale
    omnictl
    fluxcd
    hcloud
    kubectl
    krew
    kubelogin-oidc
    talosctl
    jq
    curl
  ];


}
