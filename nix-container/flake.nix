{
  description = "Alpine Linux Container";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          container = pkgs.dockerTools.buildLayeredImage {
            name = "alpine-container";
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
            contents = with pkgs; [
              coreutils
              bash
              git
              gh
              direnv
              nix-serve
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
            # Set up nix configuration
          extraCommands = ''
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
          
          default = self.packages.${system}.container;
        };
      }
    );
}