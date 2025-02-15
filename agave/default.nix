{ pkgs, lib, stdenv }:
let

  solanaPkgs = [
      "agave-ledger-tool"
      "agave-validator"
      "agave-watchtower"
      "solana"
      "solana-bench-tps"
      "solana-dos"
      "solana-faucet"
      "solana-genesis"
      "solana-gossip"
      "solana-keygen"
      "solana-log-analyzer"
      "solana-net-shaper"
      "solana-stake-accounts"
      "solana-test-validator"
      "solana-tokens"

      # "cargo-build-sbf"
      # "cargo-test-sbf"
    ];

  version = "2.1.11";
  rocksdb = pkgs.rocksdb;
in
pkgs.rustPlatform.buildRustPackage rec {
  pname = "solana-cli";
  inherit version;

  src = pkgs.fetchFromGitHub {
    owner = "anza-xyz";
    repo = "agave";
    rev = "v${version}";
    hash = "sha256-Wtc5+PkuZdicreImj9n0qqk6ZVwBZSlJytO1WTMoiMw=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;

    outputHashes = {
      "crossbeam-epoch-0.9.5" = "sha256-Jf0RarsgJiXiZ+ddy0vp4jQ59J9m0k3sgXhWhCdhgws=";
    };
  };

  strictDeps = true;
  cargoBuildFlags = builtins.map (n: "--bin=${n}") solanaPkgs;

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

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd solana \
      --bash <($out/bin/solana completion --shell bash) \
      --fish <($out/bin/solana completion --shell fish)

    mkdir -p $out/bin/sdk/sbf
    cp -a ./sdk/sbf/* $out/bin/sdk/sbf/
  '';

  # Used by build.rs in the rocksdb-sys crate. If we don't set these, it would
  # try to build RocksDB from source.
  ROCKSDB_LIB_DIR = "${rocksdb}/lib";

  # If set, always finds OpenSSL in the system, even if the vendored feature is enabled.
  OPENSSL_NO_VENDOR = 1;

  meta = with lib; {
    description = "Web-Scale Blockchain for fast, secure, scalable, decentralized apps and marketplaces";
    homepage = "https://anza.xyz";
    license = licenses.asl20;
    platforms = platforms.unix;
  };

  # passthru.updateScript = nix-update-script { };
}

