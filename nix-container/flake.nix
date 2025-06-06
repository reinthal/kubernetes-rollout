{
  description = "Nix Containers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
    template.url = "github:reinthal/template";
    template.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, template }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        baseExtraCommands = ''
            # Create necessary directories for Nix
            mkdir -p etc/nix
            mkdir -p nix/var/nix/profiles
            mkdir -p nix/var/nix/db
            mkdir -p nix/store
            
            # Basic Nix configuration
            cat > etc/nix/nix.conf <<EOF
            sandbox = false
            experimental-features = nix-command flakes
            build-users-group =
            EOF
          ''; 
        basePackages = with pkgs; [
          coreutils
          bash
          nix
          cacert
          bash
          coreutils
          curl
          git
          gnused
          gnutar
          gzip
          xz
        ];
        # Get the devshell packages from the template
        templateDevShellPackages = template.devShells.${system}.default.buildInputs;
      in
      {
        packages = {
          alpine-nix = pkgs.dockerTools.buildLayeredImage {
            name = "alpine-nix";
            tag = "3.22";
            
            # Use Alpine as the base image
            fromImage = pkgs.dockerTools.pullImage {
              imageName = "alpine";
              imageDigest = "sha256:8a1f59ffb675680d47db6337b49d22281a139e9d709335b492be023728e11715"; 
              sha256 = "sha256-ZtnqwrMHpDZiK5NwLX7cVjWt+Y1HyRR1KMf5sUlp6YA="; 
              finalImageTag = "3.22";
              finalImageName = "alpine";
            };
            
            # You can add additional packages if needed
            contents = basePackages;
            # Set up nix configuration
          extraCommands = baseExtraCommands;
            config = {
              Cmd = [ "/bin/sh" ];
              WorkingDir = "/";
              Env = [
              "NIX_PATH=nixpkgs=${nixpkgs}"
              "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
              "PATH=/bin:/usr/bin:/nix/var/nix/profiles/default/bin"
              "NIX_SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
            ];
            };
          };

          action-runner-nix = pkgs.dockerTools.buildLayeredImage {
            name = "action-runner-nix";
            tag = "v2.325.0-ubuntu-22.04";
            
            # Use summerwind/ubuntu-22.04 as the base image
            fromImage = pkgs.dockerTools.pullImage {
              imageName = "summerwind/actions-runner";
              imageDigest = "sha256:bcc6662430de0b560c7658a0c664231efdaf6a8e4c06d2e4b1cbea131d96bd2b";
              sha256 = "sha256-2o9BucepJNZffcA4y6+ge0EyyNITKxhUFdVhPrMyCfY="; 
              finalImageTag = "v2.325.0-ubuntu-22.04";
              finalImageName = "summerwind/actions-runner";
            };
            
            contents = basePackages ++ [ pkgs.direnv pkgs.gh pkgs.git-lfs ] ++ templateDevShellPackages;
            extraCommands = baseExtraCommands;
            config = {
              Cmd = [ "/bin/bash" ];
              WorkingDir = "/";
              Env = [
                "NIX_PATH=nixpkgs=${nixpkgs}"
                "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
                "PATH=/bin:/usr/bin:/nix/var/nix/profiles/default/bin"
                "NIX_SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
              ];
              Volumes = {
                "/nix/store" = {};
                "/nix/var/nix/db" = {};
              };
            };
          };
          
          default = self.packages.${system}.alpine-nix;
        };
      }
    );
}
