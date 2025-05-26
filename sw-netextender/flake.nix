{
  description = "Flake providing the SonicWall NetExtender package";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      neVersion = "10.3.0-21";
      neUrl     = "https://software.sonicwall.com/NetExtender/NetExtender-linux-amd64-${neVersion}.tar.gz";
    in
    {
      overlays = lib.genAttrs systems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in {
          netextender = pkgs.stdenv.mkDerivation rec {
            pname   = "netextender";
            version = neVersion;
            src     = pkgs.fetchurl { url = neUrl; sha256 = "sha256-pnF/KRQMAcPnTj0Ni+sKKkw+H72WHf2iYVkWsWNCndc="; };

            nativeBuildInputs = [ pkgs.autoPatchelfHook pkgs.makeWrapper ];
            buildInputs       = [ pkgs.openssl_1_1 pkgs.zlib pkgs.gtk2 pkgs.pango pkgs.cairo pkgs.xorg.libX11 ];

            unpackPhase = "tar -xzf $src";
            installPhase = ''
              mkdir -p $out/bin
              BIN_CLI=$(find . -type f -iname nxcli -perm -111 | head -n1)
              BIN_SVC=$(find . -type f -iname neservice -perm -111 | head -n1)
              install -Dm755 "$BIN_CLI" $out/bin/nxcli
              install -Dm755 "$BIN_SVC" $out/bin/neservice
              ln -sf nxcli $out/bin/netextender
              ln -sf neservice $out/bin/nxservice
              for exe in nxcli neservice; do
                wrapProgram $out/bin/$exe \
                  --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}
              done
            '';
          };
        }
      );
    }
