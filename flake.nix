{
  description = "A custom launcher for Minecraft that allows you to easily manage multiple installations of Minecraft at once (Fork of MultiMC)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    libnbtplusplus = {
      url = "github:PrismLauncher/libnbtplusplus";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    libnbtplusplus,
    ...
  }: let
    # User-friendly version number.
    version = builtins.substring 0 8 self.lastModifiedDate;

    # Supported systems (qtbase is currently broken for "aarch64-darwin")
    supportedSystems = with flake-utils.lib.system; [
      x86_64-linux
      x86_64-darwin
      aarch64-linux
    ];

    packagesFn = pkgs: rec {
      prismlauncher-qt5 = pkgs.libsForQt5.callPackage ./nix {
        inherit version self libnbtplusplus;
      };
      prismlauncher = pkgs.qt6Packages.callPackage ./nix {
        inherit version self libnbtplusplus;
      };
    };
  in
    flake-utils.lib.eachSystem supportedSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages = let
        packages = packagesFn pkgs;
      in
        packages // {default = packages.prismlauncher;};

      overlay = final: packagesFn;
    });
}
