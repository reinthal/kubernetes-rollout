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
    hcloud
    kubectl
    kubelogin
    talosctl
    jq
    curl
  ];


}
