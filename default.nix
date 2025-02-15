{ pkgs }:
let
  # used by anchor for getting an older rust version
  rust_overlay = import (builtins.fetchTarball {
    url = "https://github.com/oxalica/rust-overlay/archive/5c571e5ff246d8fc5f76ba6e38dc8edb6e4002fe.tar.gz"; # master
    sha256 = "0s28n7q30vw13g6csxlvbfp2l3jqiqk8y5swhfs320azgi6hp0b0"; # 2025-02-08T18·00+00
  });

  overlayPkgs = pkgs.extend (final: prev:
    (rust_overlay final prev)
  );

  lib = pkgs.lib;
  stdenv = pkgs.stdenv;
in
{
  agave = import ./agave { inherit pkgs lib stdenv; };
  spl = import ./spl { inherit pkgs lib stdenv; };
  anchor = import ./anchor { pkgs = overlayPkgs; inherit lib stdenv; };
  weather-rs = import ./weather { inherit pkgs; };
}
