{ atomEnv
, autoPatchelfHook
, dpkg
, fetchurl
, makeDesktopItem
, makeWrapper
, stdenv
, udev
, wrapGAppsHook
}:

stdenv.mkDerivation rec {
  pname = "termius";
  version = "5.6.1";

  src = fetchurl {
    url = "https://www.termius.com/download/linux/Termius.deb";
    sha256 = "0vgrkb4f9d47vr8dgl6rwjq0q5slxzhwlvrnafdjnxcx8vhy2g54";
  };

  desktopItem = makeDesktopItem {
    categories = "Network;";
    comment = "The SSH client that works on Desktop and Mobile";
    desktopName = "Termius";
    exec = "termius-app";
    genericName = "Cross-platform SSH client";
    icon = "termius-app";
    name = "termius-app";
  };

  dontBuild = true;
  dontConfigure = true;
  dontPatchELF = true;
  dontWrapGApps = true;

  nativeBuildInputs = [ autoPatchelfHook dpkg makeWrapper wrapGAppsHook ];

  buildInputs = atomEnv.packages;

  unpackPhase = "dpkg-deb -x $src .";

  installPhase = ''
    mkdir -p "$out/bin"
    cp -R "opt" "$out"
    cp -R "usr/share" "$out/share"
    chmod -R g-w "$out"
    # Desktop file
    mkdir -p "$out/share/applications"
    cp "${desktopItem}/share/applications/"* "$out/share/applications"
  '';

  runtimeDependencies = [ udev.lib ];

  postFixup = ''
    makeWrapper $out/opt/Termius/termius-app $out/bin/termius-app \
      "''${gappsWrapperArgs[@]}"
  '';

  meta = with stdenv.lib; {
    description = "A cross-platform SSH client with cloud data sync and more";
    homepage = "https://termius.com/";
    downloadPage = "https://termius.com/linux/";
    license = licenses.unfree;
    maintainers = with maintainers; [ filalex77 ];
    platforms = [ "x86_64-linux" ];
  };
}
