{ lib, stdenv, makeWrapper, rakudo, zef }:
{ name, src
, buildInputs ? [], depends ? [], propagatedBuildInputs ? []
, preInstallPhase ? "true", postInstallPhase ? "true" }:
stdenv.mkDerivation {
    inherit name src;

    buildInputs = [makeWrapper rakudo] ++ buildInputs;
    propagatedBuildInputs = [ depends ] ++ propagatedBuildInputs;

    phases = ["unpackPhase"  "preInstallPhase"
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
    
        mkdir --p $out

        # Create the LD_LIBRARY_PATH for propagated inputs
        export RAKUDO_LD_LIBRARY_PATH="${stdenv.lib.makeSearchPathOutput "lib" "lib" (stdenv.lib.misc.closePropagation(propagatedBuildInputs))}''${RAKUDO_LD_LIBRARY_PATH:+:''${RAKUDO_LD_LIBRARY_PATH}}"

        export RAKUDOLIB="inst#$out''${RAKUDOLIB:+,''${RAKUDOLIB}}"


        # Create a hook to propagate the LD_LIBRARY_PATH used by for
        # NativeCaller etc.
        mkdir -p $out/nix-support/
        cat <<EOF >> $out/nix-support/setup-hook
            export RAKUDOLIB="\''${RAKUDOLIB:+''${RAKUDOLIB},}$RAKUDOLIB"
            export RAKUDO_LD_LIBRARY_PATH="\''${RAKUDO_LD_LIBRARY_PATH:+''${RAKUDO_LD_LIBRARY_PATH}:}$RAKUDO_LD_LIBRARY_PATH"
        EOF

        env RAKUDOLIB=$RAKUDOLIB \
            LD_LIBRARY_PATH=$RAKUDO_LD_LIBRARY_PATH \
            HOME=$TMPDIR \
            ${zef}/bin/zef --/depends --/test-depends --/build-depends --install-to=$out install .


        #     raku ${./install.raku} \
        #         --dist-path=$PWD \
        #         --repo-spec=inst\#$out

        # # Wrap each executable so that it can find all dependencies.
        # rm -f $out/bin/*-{j,js,m} # XXX: indiscriminate removing of stuff
        # for bin in $out/bin/*; do
        #     hidden=$out/bin/.$(basename "$bin")-wrapped
        #     mv "$bin" "$hidden"
        #     makeWrapper ${rakudo}/bin/raku "$bin" \
        #         --set RAKUDOLIB $(< $out/RAKUDOLIB) \
        #         --add-flags "$hidden"
        # done



    '';
}
