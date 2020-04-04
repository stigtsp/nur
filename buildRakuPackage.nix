{ lib, stdenv, makeWrapper, rakudo, zef, toRakuPackage, requiredRakuPackages }:
{ name, src
, buildInputs ? [], depends ? [], propagatedBuildInputs ? []
, preInstallPhase ? "true", postInstallPhase ? "true", patches ? [] }:
toRakuPackage(stdenv.mkDerivation ({
    inherit name src patches;

    buildInputs = [makeWrapper rakudo] ++ buildInputs;
    propagatedBuildInputs = [ depends ] ++ propagatedBuildInputs;

    phases = ["unpackPhase"  "patchPhase" "preInstallPhase"
              "installPhase" "postInstallPhase" "fixupPhase"];
    inherit  preInstallPhase postInstallPhase;

    # XXX: Do tests  `perl6 -r -I. t/` need RAKUDOLIB

    # checkPhase = ''
    #     mkdir --parents $out
    #     RAKUDOLIB=${lib.concatMapStringsSep "," (p: "$(cat ${p}/RAKUDOLIB)") depends}
    #     echo checkPhase
    #     printenv
    #     env RAKUDOLIB=$RAKUDOLIB ${rakudo}/bin/rakudo -I.  t/*.t
    # '';
    # doCheck=false;

    

    installPhase = ''
        set -x
        mkdir -p $out

        # Create the LD_LIBRARY_PATH for propagated inputs
        export RAKUDO_LD_LIBRARY_PATH="${stdenv.lib.makeSearchPathOutput "lib" "lib" (propagatedBuildInputs)}''${RAKUDO_LD_LIBRARY_PATH:+:''${RAKUDO_LD_LIBRARY_PATH}}"
        export RAKUDOLIB="inst#$out''${RAKUDOLIB:+,''${RAKUDOLIB}}"

        # Create a hook to propagate the LD_LIBRARY_PATH used by for
        # NativeCaller etc.
        mkdir -p $out/nix-support/
        cat <<EOF >> $out/nix-support/setup-hook
            export RAKUDOLIB="\''${RAKUDOLIB:+\''${RAKUDOLIB},}$RAKUDOLIB"
            export RAKUDO_LD_LIBRARY_PATH="\''${RAKUDO_LD_LIBRARY_PATH:+\''${RAKUDO_LD_LIBRARY_PATH}:}$RAKUDO_LD_LIBRARY_PATH"
        EOF

        set +x

        env RAKUDOLIB=$RAKUDOLIB \
            LD_LIBRARY_PATH=$RAKUDO_LD_LIBRARY_PATH \
            HOME=$TMPDIR \
            ${zef}/bin/zef --/depends --/test-depends --/build-depends --install-to=$out install .


    '';
} 
//
{
  pname = "rakudo${rakudo.version}-${name}"; # TODO: phase-out `attrs.name`
  version = "0.0";#lib.getVersion attrs;                     # TODO: phase-out `attrs.name`
}
))
