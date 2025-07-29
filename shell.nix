{ nixpkgs ? import <nixpkgs> {}
}:

with nixpkgs;

stdenv.mkDerivation rec {
  name = "python-virtualenv-shell";
  env = buildEnv { name = name; paths = buildInputs; };
  buildInputs = [
    python3
    virtualenv
  ];
  shellHook = ''
    # set SOURCE_DATE_EPOCH so that we can use python wheels
    SOURCE_DATE_EPOCH=$(date +%s)
  '';
}
