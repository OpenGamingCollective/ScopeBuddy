{
  stdenvNoCC,
  makeWrapper,
  lib,
  gamescope,
  xwayland,
  perl,
  jq,
  wlr-randr,
}:

stdenvNoCC.mkDerivation {
  pname = "scopebuddy";
  version = "git";
  src = lib.cleanSource ./..;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -Dm755 bin/scopebuddy $out/bin/scopebuddy
    ln -s $out/bin/scopebuddy $out/bin/scb

    wrapProgram $out/bin/scopebuddy \
      --prefix PATH : ${
        lib.makeBinPath [
          gamescope
          xwayland
          perl
          jq
          wlr-randr
        ]
      }
  '';

  meta = with lib; {
    description = "A manager script to make gamescope easier to use on desktop";
    homepage = "https://github.com/OpenGamingCollective/ScopeBuddy";
    license = licenses.asl20;
    platforms = platforms.linux;
    mainProgram = "scopebuddy";
  };
}
