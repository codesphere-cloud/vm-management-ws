{ hostPkgs ? import <nixpkgs> {} }:

let
  pinnedNixpkgs = import (hostPkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "23.05";
    sha256 = "sha256-btHN1czJ6rzteeCuE/PNrdssqYD2nIA4w48miQAFloM=";
  }) {};

  pkgs = pinnedNixpkgs;

  guacamoleServerVersion = "1.5.5";
  guacamoleServerSrc = pkgs.fetchurl {
    url = "https://downloads.apache.org/guacamole/${guacamoleServerVersion}/source/guacamole-server-${guacamoleServerVersion}.tar.gz";
    sha256 = "sha256-Z0mWEcLiLZyTN2OtxUCOcWpL/Qij64pbovxvj3CGj2s=";
  };

  # Define our dependencies in one place to use them in two spots later
  guacBuildInputs = with pkgs; [
    cairo libjpeg libpng libossp_uuid pango freerdp libvncserver
    libssh2 libtelnet libwebsockets openssl libxkbcommon pulseaudio
    libvorbis ffmpeg libwebp
  ];

in
pkgs.stdenv.mkDerivation {
  pname = "guacamole-server";
  version = guacamoleServerVersion;
  src = guacamoleServerSrc;

  nativeBuildInputs = with pkgs; [
    autoconf automake libtool pkg-config perl
  ];

  buildInputs = guacBuildInputs;

  CFLAGS = "-Wno-error=deprecated-declarations";

  configureFlags = [
    "--with-freerdp-plugin-dir=${placeholder "out"}/lib/freerdp2"
  ];

  # THIS IS THE FINAL FIX: Correct the paths from /bin to /sbin for the real daemon.
  postInstall = ''
    # Move the real binary from its actual installation location in sbin
    mv $out/sbin/guacd $out/sbin/guacd-real

    # Ensure the user-facing bin directory exists
    mkdir -p $out/bin

    # Create the new wrapper script in the user-facing bin directory
    cat > $out/bin/guacd << EOF
    #!${pkgs.bash}/bin/sh
    # Set the environment variable telling guacd where to find its plugins.
    export GUACAMOLE_PLUGIN_PATH="$out/lib/guacamole"
    
    # Set the environment variable telling the dynamic linker where ALL .so files are.
    export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath guacBuildInputs}:$out/lib"
    
    # Execute the real binary from its sbin location, passing along all arguments.
    exec "$out/sbin/guacd-real" "\$@"
    EOF

    # Make the wrapper script executable
    chmod +x $out/bin/guacd
  '';

  meta = with pkgs.lib; {
    description = "Core components of Apache Guacamole: guacd, libguac, and protocol support libraries";
    homepage = "http://guacamole.apache.org/";
    platforms = platforms.linux;
  };
}