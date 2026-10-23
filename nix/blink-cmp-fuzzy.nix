{
  rustPlatform,
  git,
  src,
}:
rustPlatform.buildRustPackage {
  pname = "blink-cmp-fuzzy";
  version = "0.1.0";

  inherit src;

  nativeBuildInputs = [ git ];

  cargoLock.lockFile = src + /Cargo.lock;
}
