{ pkgs, lib, stdenv }:
let
  splPkgs = [
      "spl-token"
    ];

  version = "5.0.0";
  rocksdb = pkgs.rocksdb;
in
pkgs.rustPlatform.buildRustPackage rec {
  pname = "spl-token-cli";
  inherit version;

  src = pkgs.fetchFromGitHub {
    owner = "solana-labs";
    repo = "solana-program-library";
    rev = "token-cli-v${version}";
    hash = "sha256-LV/QeQgnHI06/QJ1O6gXP6esPcJew8/LqFgQLRRGPP8=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;

    outputHashes = {
      # "crossbeam-epoch-0.9.5" = "sha256-Jf0RarsgJiXiZ+ddy0vp4jQ59J9m0k3sgXhWhCdhgws=";
    };
  };

  strictDeps = true;
  cargoBuildFlags = builtins.map (n: "--bin=${n}") splPkgs;

  # Even tho the tests work, a shit ton of them try to connect to a local RPC
  # or access internet in other ways, eventually failing due to Nix sandbox.
  # Maybe we could restrict the check to the tests that don't require an RPC,
  # but judging by the quantity of tests, that seems like a lengthty work and
  # I'm not in the mood ((ΦωΦ))
  doCheck = false;

  nativeBuildInputs = [
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
    description = "Web-Scale Blockchain for fast, secure, scalable, decentralized apps and marketplaces";
    homepage = "https://solana.com";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}

