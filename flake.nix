{
  description = "Dumme hellow world";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs = { self, nixpkgs, ... }:
    let

      # Generate a user-friendly version number.
      version = builtins.substring 0 8 self.lastModifiedDate;

      # System types to support.
      supportedSystems =
        [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

    in
    {

      packages = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in rec {
          nix_sample = pkgs.buildGoModule {
            pname = "nix_sample";
            inherit version;
            src = ./.;
            vendorSha256 =
              "sha256-PEn81rz846WwG+zaWyJ7aRCh4tF4ifaF7rbMfy3PMB0=";
          };
          default = nix_sample;
        });

      apps = forAllSystems (system: rec {
        nix_sample = {
          type = "app";
          program = "${self.packages.${system}.nix_sample}/bin/nix_sample";
        };
        default = nix_sample;
      });

      defaultPackage = forAllSystems (system: self.packages.${system}.default);

      defaultApp = forAllSystems (system: self.apps.${system}.default);

      devShells = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [ go_1_20 gopls gotools  ];
            GOROOT = "${pkgs.go}/share/go";
          };
        });

      devShell = forAllSystems (system: self.devShells.${system}.default);
    };
}
