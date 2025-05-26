# SonicWall NetExtender Nix Overlay

[1] import overlay

inputs.netextender.url = "path:/";

[2] include overlay in config.nix

outputs = { self, nixpkgs, netextender, ... }:
  let pkgs = import nixpkgs { system = "x86_64-linux"; overlays = [ netextender.overlays.x86_64-linux ]; };
  in {
    devShell = pkgs.mkShell {
      buildInputs = [ pkgs.netextender ];
    };
  };


If you need to add other targets (for ARM, etc) tweak the systems in the flake
