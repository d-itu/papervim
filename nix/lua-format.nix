{
  rustPlatform,
  src,
}:
rustPlatform.buildRustPackage {
  pname = "lua-format";
  version = "0.1.0";

  inherit src;

  cargoLock.lockFile = src + /Cargo.lock;
}
