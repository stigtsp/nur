{ stdenv, fetchurl, perl, icu, zlib, gmp, lib, nqp }:

stdenv.mkDerivation rec {
  pname = "rakudo";
  version = "2019.11";

  src = fetchurl {
    url    = "https://github.com/rakudo/rakudo/releases/download/${version}/rakudo-${version}.tar.gz";
    sha256 = "0camnv73b2gqkdc6f70fjzq4r7pgri8xh0jn7rrdvdd8sxh93q9n";
  };

  buildInputs = [ icu zlib gmp perl ];
  configureScript = "perl ./Configure.pl";
  configureFlags = [
    "--backends=moar"
    "--with-nqp=${nqp}/bin/nqp"
  ];

  # Some tests fail on Darwin
  doCheck = !stdenv.isDarwin;

  meta = with stdenv.lib; {
    description = "Raku implementation on top of Moar virtual machine";
    homepage    = https://www.rakudo.org;
    license     = licenses.artistic2;
    platforms   = platforms.unix;
    maintainers = with maintainers; [ thoughtpolice vrthra sgo ];
  };
}
