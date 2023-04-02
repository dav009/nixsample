{
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";


  

  
  inputs.sampleproject = {
    url = "git+ssh://git@github.com/dav009/nix_sample.git?ref=main";
    flake = true;
  };

  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };



  outputs = { self, nixpkgs, sampleproject, ... }:
    let
      supportedSystems = [ "aarch64-linux" "aarch64-darwin" ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      packages = forAllSystems
        (system:
          let
            pkgs = nixpkgsFor.${system};
          in
          {
            sample = pkgs.writeTextFile
              {
                name = "my-file";
                text = ''
                  Contents of File ${sampleproject.packages.${system}.nix_sample}
                '';
              };
          });
    };
}
