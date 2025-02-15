{ pkgs }:
let
  version = "0.1.0";
in
pkgs.rustPlatform.buildRustPackage {
  pname = "weather-rs";
  inherit version;

  src = pkgs.fetchFromGitHub {
    owner = "chellipse";
    repo = "weather-rs";
    rev = "f2e9d642cfd4e07044651745fc2bb1713cc59af7";
    hash = "sha256-vY/iYeHaPNeAWcPP/jf9HR0vRdGcxYJyYUWrlbPC8Mg=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  nativeBuildInputs = [
    pkgs.pkg-config
  ];

  buildInputs = [
    pkgs.openssl
    pkgs.rustPlatform.bindgenHook
  ];
}

