{ pkgs ? import <nixpkgs> {} }:
with pkgs;
rec {
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  rakudo = callPackage ./pkgs/rakudo { nqp = nqp; };
  moarvm = callPackage ./pkgs/rakudo/moarvm.nix {
    inherit (darwin.apple_sdk.frameworks) CoreServices ApplicationServices;
  };
  nqp = callPackage ./pkgs/rakudo/nqp.nix { moarvm = moarvm; };
  zef = callPackage ./pkgs/rakudo/zef.nix { rakudo = rakudo; };

  rakuPackage = pkgs.callPackage ./pkgs/rakudo/rakuPackage.nix { rakudo = rakudo; zef = zef; };

  rakuPackages = {
    Base64 = rakuPackage {
      name = "Base64";
      src = fetchTarball {
        url = "https://github.com/ugexe/Perl6-Base64/archive/199788b195ca0c1ed80c4e44496c9dd3953df838.tar.gz";
        sha256 = "1gmfpixmms13xvbv2pn34r4h6aa3p7l709c1igpkbg2j2bz5vzhs";
      };
    };
    Cro-Core = rakuPackage {
      name = "Cro-Core";
      src = fetchTarball {
        url = "https://github.com/croservices/cro-core/archive/5d2157d26f2973d16bbf4710aa1609b713f368ca.tar.gz";
        sha256 = "1cdq7dxqhzl8m76dh9cqlqgjfb6c6yqqyp3mxizj4jfphmcg6wkv";
      };
    };
    Cro-HTTP = rakuPackage {
        name = "Cro-HTTP";
        buildInputs = [ openssl_1_0_2 ];
        depends = [
          rakuPackages.Base64
          rakuPackages.Cro-Core
          rakuPackages.Cro-TLS
          rakuPackages.Crypt-Random
          rakuPackages.DateTime-Parse
          rakuPackages.HTTP-HPACK
          rakuPackages.IO-Path-ChildSecure
          rakuPackages.IO-Socket-Async-SSL
          rakuPackages.JSON-Fast
          rakuPackages.JSON-JWT
          rakuPackages.Log-Timeline
          rakuPackages.OO-Monitors
        ];
        src = fetchTarball {
          url = "https://github.com/croservices/cro-http/archive/9195f51b30d4090550a07732efbfd98c3056573a.tar.gz";
          sha256 = "0zmjy6yhq2xzczpyz7id40nrmaimr6vlpy34li1gjizwbydgf95n";
        };
        preInstallPhase = ''
          # This package likes to use HOME during compilation.
          mkdir home
          export HOME=$PWD/home
       '';
      };
    Cro-TLS = rakuPackage {
        name = "Cro-TLS";
        depends = [
          rakuPackages.Cro-Core
          rakuPackages.IO-Socket-Async-SSL
        ];
        src = fetchTarball {
          url = "https://github.com/croservices/cro-tls/archive/b504b68504903f7ac83cc60dd79a0b9ac8cddb74.tar.gz";
          sha256 = "0gnphi3drhfwgr6bflh3qpsf8pi49ndh3s2y2w73l6xks2g0w0bn";
        };
        preInstallPhase = ''
          # This package likes to use HOME during compilation.
          mkdir home
          export HOME=$PWD/home
        '';
      };
    Crypt-Random = rakuPackage {
      name = "Crypt-Random";
      depends = [rakuPackages."if"];
      src = fetchTarball {
        url = "https://github.com/skinkade/crypt-random/archive/c1bf9393ab736ac5e5de2d0c3f56078c178cc071.tar.gz";
        sha256 = "0b0xkdv714dkxqwdv3gpaps06pc42sqxhq7n638ridh2zapnf1yx";
      };
    };
    DateTime-Parse = rakuPackage {
      name = "DateTime-Parse";
      src = fetchTarball {
        url = "https://github.com/sergot/datetime-parse/archive/acf2f4f493891d3accdc25e8209ce275899d5dd2.tar.gz";
        sha256 = "0rqxcgccq2ipyawhx2pgb8yk99zgrylg0ia7ra5p78dpsqywb30v";
      };
    };
    DBIish = rakuPackage {
      name = "DBIish";
      depends = [rakuPackages.NativeHelpers-Blob];
      src = fetchTarball {
        url = "https://github.com/perl6/DBIish/archive/d89c8c842e467c26f679cb65913d2fe9aded1a6d.tar.gz";
        sha256 = "11hvjjx9ghq01mx6q2ar6h2mc7vskhmyl4472hzfqa48xvdvjnm4";
      };
    };
    Digest-HMAC = rakuPackage {
      name = "Digest-HMAC";
      depends = [rakuPackages.Digest];
      src = fetchTarball {
        url = "https://github.com/retupmoca/P6-Digest-HMAC/archive/dcc292d77c7158eb7b53d3673cbee66d8b7b4fdf.tar.gz";
        sha256 = "1dpxz370gj4cl80p4jjfl554vxfkiq8vlx2cjkvfmv86bijmm5zg";
      };
    };
    Digest = rakuPackage {
      name = "Digest";
      src = fetchTarball {
        url = "https://github.com/grondilu/libdigest-perl6/archive/42ba6bef6ca5a9e532ad1436465df7af0cd5f70c.tar.gz";
        sha256 = "1ch0j1m3brngby9l1zddvf10kkkdrn7ghnyy9j06k9rf792frds9";
      };
    };
    HTTP-HPACK = rakuPackage {
      name = "HTTP-HPACk";
      src = fetchTarball {
        url = "https://github.com/jnthn/p6-http-hpack/archive/608a74c5f56d76891ce9c7f9422320e9fdd5b6af.tar.gz";
        sha256 = "1n6pwqw8w5jf3fidpgyrvxxhwzz12yni6iishbb5bxkxyv96g00x";
      };
    };
    "if" = rakuPackage {
      name = "if";
      depends = [];
      src = fetchTarball {
        url = "https://github.com/FROGGS/p6-if/archive/d4ef4186a0837b405dfda652d3ed58ceecb0a082.tar.gz";
        sha256 = "0cc1wfx77q1nsbn4p4zxd8ihjspbplbsycy8kqn70is4yjsqr1c0";
      };
    };
    Inline-Perl5 = rakuPackage {
      name = "Inline-Perl5";

      buildInputs = [perl];
      depends = [rakuPackages.LibraryMake];

      src = fetchTarball {
        url = "https://github.com/niner/Inline-Perl5/archive/96b4b9b502c4bcb32ee9d7c9c7a84072405e5d00.tar.gz";
        sha256 = "1lcq2cyhcz1lj9047ybiniyal9zrkwdl6lx68pvd7yf2ww9v3snh";
      };

      preInstallPhase = ''
        raku configure.pl6
        make
    '';
    };
    IO-Path-ChildSecure = rakuPackage {
      name = "IO-Path-ChildSecure";
      src = fetchTarball {
        url = "https://github.com/perl6-community-modules/perl6-IO-Path-ChildSecure/archive/d98c6f45c8a7152e3676b0c39166a62598dbcbf4.tar.gz";
        sha256 = "11a2i6lpdkgifp89lss1gzjmkxcnarinjqxam1xwzhf24idrcdwm";
      };
    };
    IO-Socket-Async-SSL = rakuPackage {
      name = "IO-Socket-Async-SSL";
      buildInputs = [ openssl ];
      depends = [
        rakuPackages.OpenSSL
      ];
      src = fetchTarball {
        url = "https://github.com/jnthn/p6-io-socket-async-ssl/archive/b28fa9ebea6595c2c3cb1a3df3419f06447add00.tar.gz";
        sha256 = "0b8vw1rwnb7a5v4c4fdmgkglzp4pwgfcxmcdmv0nl47vl1xgxyby";
      };
    };
    JSON-Fast = rakuPackage {
      name = "JSON-Fast";
      src = fetchTarball {
        url = "https://github.com/timo/json_fast/archive/eb6ae0d339ed2441eb9df7758e3e1b6609eb5141.tar.gz";
        sha256 = "1pgnqyfbzh1x5f6040766yck8rxfq60yr75jcgh6fylcgavm0sfr";
      };
    };
    JSON-JWT = rakuPackage {
      name = "JSON-JWT";
      depends = [
        rakuPackages.Digest-HMAC
        rakuPackages.JSON-Fast
        rakuPackages.MIME-Base64
        rakuPackages.OpenSSL
      ];
      src = fetchTarball {
        url = "https://github.com/retupmoca/P6-JSON-JWT/archive/cf0dceb420aa7b62b2ff5509acddc6f3133e82c8.tar.gz";
        sha256 = "0q65q3w89cw1j3mrxnpr1yg2mrddi8jpm27rmlfl87c1bzlkzqrl";
      };
    };
    LibraryMake = rakuPackage {
      name = "LibraryMake";
      src = fetchTarball {
        url = "https://github.com/retupmoca/P6-LibraryMake/archive/7aae514f09c18b54e2a5d584df340b70d9776a6d.tar.gz";
        sha256 = "1969ihjavpxiz0vy1sc2pd9hk8dsz00wvy9lz0lpd0rl8y6f7zfb";
      };
    };
    Log-Timeline = rakuPackage {
      name = "Log-Timeline";
      depends = [
        rakuPackages.JSON-Fast
      ];
      src = fetchTarball {
        url = "https://github.com/jnthn/p6-log-timeline/archive/4bd6f9a1349d74a5f7887015790d807e3addb33e.tar.gz";
        sha256 = "01la1xcvvypa8ln017czhvgkinzjza11ma9w9j5d1881xwx0xxwn";
      };
    };
    MIME-Base64 = rakuPackage {
      name = "MIME-Base64";
      src = fetchTarball {
        url = "https://github.com/perl6/Perl6-MIME-Base64/archive/71f046ab176a6dd77a5a4103a44778ed5cf1b17f.tar.gz";
        sha256 = "1il78w8aiwxcgjx6az8i5zplqfk6crn4xmvin9pw3jzv57n2qrnh";
      };
    };
    NativeHelpers-Blob = rakuPackage {
      name = "NativeHelpers-Blob";
      src = fetchTarball {
        url = "https://github.com/salortiz/NativeHelpers-Blob/archive/b00a4899ce219dae5fe97e9e414d01dd92874f53.tar.gz";
        sha256 = "08bpc361n7xrdz59jl8nbib3n2pvgncjsz12fhkqav40dvc09kqh";
      };
    };
    OO-Monitors = rakuPackage {
      name = "OO-Monitors";
      src = fetchTarball {
        url = "https://github.com/jnthn/oo-monitors/archive/6dc1a363c7859b760bf973d0ada0773cfdb14356.tar.gz";
        sha256 = "1rnw12lx12z00bff32rg5ibkc5n50cyh8788qzprlb0z6ahz1qms";
      };
    };
    OpenSSL = rakuPackage {
      name = "OpenSSL";
      propagatedBuildInputs = [ openssl ];
      src = fetchTarball {
        url = "https://github.com/sergot/openssl/archive/597e836c73684bb53ac5cb4511edca9b4f10ea87.tar.gz";
        sha256 = "0mw7747vsdaq34l7c002k2bb3q4bwwgwhz5ial7h1plyzr6xjkyi";
      };
    };
    Pod-Load = rakuPackage {
      name = "Pod-Load";
      src = fetchTarball {
        url = "https://www.cpan.org/authors/id/J/JM/JMERELO/Perl6/pod-load-0.5.5.tgz";
        sha256 = "0an94km1hls1n4mivr84njh1xkm43yq17ap6fdyj66wqksjpp5ni";
      };
    };
    Pod-To-HTML = rakuPackage {
      name = "Pod-To-HTML";

      depends = [
        rakuPackages.URI
        rakuPackages.Template-Mustache
        rakuPackages.Pod-Load
      ];

      src = fetchTarball {
        url = "https://github.com/perl6/Pod-To-HTML/archive/8ddda65e0504ef2ca3f21c17f611aca00011dcce.tar.gz";
        sha256 = "0prhq1hjajp8gxxcvlkiq4bspn69x6lk5pc5fgr45h91nnn72dbn";
      };
    };
    Template-Classic = rakuPackage {
      name = "Template-Classic";
      src = fetchTarball {
        url = "https://github.com/chloekek/Template-Classic/archive/45b455c08658ead583d5ac08ce3554a52711fb6b.tar.gz";
        sha256 = "0a8pdn4y36dbxl4lfxgyndi6jy0h8hb6cmadiirblv5ja4kbpppj";
      };
    };
    Template-Mustache = rakuPackage {
      name = "Template-Mustache";
      src = fetchTarball {
        url = "https://github.com/softmoth/p6-Template-Mustache/archive/4f09e0a97f38fe5d8c75514ca0c858cdfb26d09b.tar.gz";
        sha256 = "14gjbslrhdfqi10fpqznqpmar5gh2wdn2yd5h1iz2mwmprasf1cc";
      };
    };
    Terminal-ANSIColor = rakuPackage {
      name = "Terminal-ANSIColor";
      src = fetchTarball {
        url = "https://github.com/tadzik/Terminal-ANSIColor/archive/eeb2dadd2cc2b7df34588be7869768213fd9fff4.tar.gz";
        sha256 = "1apm999azkyg5s35gid12wq019aqnvzrkz7qjmipd74mdxgr00x7";
      };
    }

    ;
    URI-Encode = rakuPackage {
      name = "URI-Encode";
      src = fetchTarball {
        url = "https://github.com/perl6-community-modules/URI-Encode/archive/5f4d747d38a16d1f8d1e572066ec9ef58323c9dc.tar.gz";
        sha256 = "045djxp1bf8415lnr3flc6awnjiszpkkm7ad859cc4vn9i5l4rvd";
      };
    };
    URI = rakuPackage {
      name = "URI";
      src = fetchTarball {
        url = "https://github.com/perl6-community-modules/URI/archive/abe8c9bb65947760cb656c6c154f466cd87f6e57.tar.gz";
        sha256 = "0km02phbx30ddjn0ygsjnn8ks3la6ms226q5mmxg73809i6ngs1r";
      };
    };

  };
}

