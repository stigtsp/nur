{ stdenv, fetchurl, perl
, CoreServices, ApplicationServices }:

stdenv.mkDerivation rec {
  pname = "moarvm";
  version = "2019.11";

  src = fetchurl {
    url    = "https://github.com/MoarVM/MoarVM/releases/download/${version}/MoarVM-${version}.tar.gz";
    sha256 = "0082hy3kl8fvgqz4d9nyxyrrhbh5jx4i1wi64ax0x01m9q8wb0nq";
  };

  buildInputs = [ perl ] ++ stdenv.lib.optionals stdenv.isDarwin [ CoreServices ApplicationServices ];
  doCheck = false; # MoarVM does not come with its own test suite

  configureScript = "${perl}/bin/perl ./Configure.pl";

  meta = with stdenv.lib; {
    description = "VM with adaptive optimization and JIT compilation, built for Rakudo";
    homepage    = "https://github.com/MoarVM/MoarVM";
    license     = licenses.artistic2;
    platforms   = platforms.unix;
    maintainers = with maintainers; [ thoughtpolice vrthra sgo ];
  };
}
