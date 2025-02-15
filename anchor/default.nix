{ pkgs, lib, stdenv }:
let
  anchorPkgs = [
    "anchor-cli"
  ];

  version = "0.30.1";
  rocksdb = pkgs.rocksdb;

  # in time-0.3.29 there is a type inference error which is new with Rust
  # 1.80.0, so we're using the stable version from directly before that.
  rust = pkgs.rust-bin.stable."1.79.0".minimal;
in
(pkgs.makeRustPlatform {
  rustc = rust;     
  cargo = rust;     
}).buildRustPackage rec {
  pname = "anchor-cli";
  inherit version;

  src = pkgs.fetchFromGitHub {
    owner = "coral-xyz";
    repo = "anchor";
    rev = "v${version}";
    hash = "sha256-3fLYTJDVCJdi6o0Zd+hb9jcPDKm4M4NzpZ8EUVW/GVw=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;

    outputHashes = {
      "serum_dex-0.4.0" = "sha256-Nzhh3OcAFE2LcbUgrA4zE2TnUMfV0dD4iH6fTi48GcI=";
    };
  };

  strictDeps = true;
  cargoBuildFlags = builtins.map (n: "--package=${n}") anchorPkgs;

  # Even tho the tests work, a shit ton of them try to connect to a local RPC
  # or access internet in other ways, eventually failing due to Nix sandbox.
  # Maybe we could restrict the check to the tests that don't require an RPC,
  # but judging by the quantity of tests, that seems like a lengthty work and
  # I'm not in the mood ((ΦωΦ))
  doCheck = false;

  nativeBuildInputs = [
    pkgs.installShellFiles
    pkgs.protobuf
    pkgs.pkg-config
  ];
  buildInputs =
    [
      pkgs.openssl
      pkgs.rustPlatform.bindgenHook
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [ pkgs.udev ];

  # Used by build.rs in the rocksdb-sys crate. If we don't set these, it would
  # try to build RocksDB from source.
  ROCKSDB_LIB_DIR = "${rocksdb}/lib";

  # If set, always finds OpenSSL in the system, even if the vendored feature is enabled.
  OPENSSL_NO_VENDOR = 1;

  meta = with lib; {
    description = "Solana Sealevel Framework";
    homepage = "https://anchor-lang.com";
    platforms = platforms.unix;
  };
}

