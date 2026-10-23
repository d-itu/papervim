{
  lib,
  stdenvNoCC,
  NVIM_APPNAME ? "nvim",
  inputs,
  lua-format,
  blink-cmp-fuzzy,
}:
let
  installPlugins = lib.pipe inputs [
    (lib.filterAttrs (name: _: name != "self"))
    (lib.mapAttrsToList (name: src: "cp -r ${src} $PREFIX/opt/${name}"))
    (builtins.concatStringsSep ";")
  ];
in
stdenvNoCC.mkDerivation {
  pname = "papervim-plugins";
  version = "0.1.0";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    PREFIX=$out/share/${NVIM_APPNAME}/site/pack/nix

    mkdir -p $PREFIX/opt
    ${installPlugins}

    chmod +w $PREFIX/opt/lua-format
    mkdir -p $PREFIX/opt/lua-format/target/release
    cp ${lua-format}/lib/liblua_format_impl.so $PREFIX/opt/lua-format/target/release

    chmod +w $PREFIX/opt/blink.cmp
    cp -r ${blink-cmp-fuzzy}/lib $PREFIX/opt/blink.cmp

    mkdir -p $PREFIX/start
    cp -r ${inputs.self}/src $PREFIX/start/papervim

    runHook postInstall
  '';
}
