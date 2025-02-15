let
  # used by anchor for getting an older rust version
  rust_overlay = import (builtins.fetchTarball {
    url = "https://github.com/oxalica/rust-overlay/archive/5c571e5ff246d8fc5f76ba6e38dc8edb6e4002fe.tar.gz"; # master
    sha256 = "0s28n7q30vw13g6csxlvbfp2l3jqiqk8y5swhfs320azgi6hp0b0"; # 2025-02-08T18·00+00
  });

  pkgs = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/2ff53fe64443980e139eaa286017f53f88336dd0.tar.gz"; # nixos-unstable
    sha256 = "0ms5nbr2vmvhbr531bxvyi10nz9iwh5cry12pl416gyvf0mxixpv"; # 2025-02-15T12·40+00
  }) { overlays = [ rust_overlay ]; };

  lib = pkgs.lib;
  stdenv = pkgs.stdenv;
in
{
  agave = import ./agave { inherit pkgs lib stdenv; };
  spl = import ./spl { inherit pkgs lib stdenv; };
  anchor = import ./anchor { inherit pkgs lib stdenv; };
}
