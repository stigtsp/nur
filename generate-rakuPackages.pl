#!/usr/bin/env perl

use v5.12;
use strict;
use version;
use warnings;

sub nix_name
{
    my ($name) = @_;
#   
    $name =~ s/::/-/g;
    $name =~ s/:.*$//;
    $name;
}

sub nix_attr_name {
    my ($name) = @_;
    $name = nix_name($name);
    my @quote = qw(if);
    $name = qq("$name") if grep {$name eq $_ } @quote;
    $name;
}

sub nix_depends
{
    map { nix_attr_name($_) }
    grep { $_ ne 'NativeCall' }
    @_;
}

if (! -e 'sqlite') {
    say 'WARNING: DOWNLOADING DATABASE WITHOUT TLS!';
    say 'PRESS ENTER TO CONTINUE.';
    scalar(<STDIN>);
    # TODO: Once I get TLS fixed on my server, use HTTPS instead of HTTP.
    system('wget "http://database.crai.foldr.nl/sqlite"')
        and die('wget');
}

open(my $sqlite, '-|', 'sqlite3', 'sqlite', <<'SQL') or die("open: $!");
    SELECT url,
           sha256_hash,
           meta_name,
           meta_version,
           ( SELECT group_concat(meta_depends.meta_depend)
             FROM   meta_depends
             WHERE  meta_depends.archive_url = archives.url )
    FROM   archives
    WHERE  sha256_hash IS NOT NULL AND
           meta_name   IS NOT NULL
SQL

my @libraries;

# First we collect all libraries.
@libraries =
    map {
        chomp;
        my @parts = split(/\|/);
        {
            # Archive properties.
            url            => $parts[0],
            sha256_hash    => $parts[1],

            # Properties from META6.json.
            meta_name      => $parts[2],
            meta_version   => $parts[3],
            meta_version_p => scalar(eval { version->parse($parts[3]) }),
            meta_depends   => [ split(/,/, $parts[4] // '') ],

            # See below.
            meta_build_depends  => [],
            meta_native_depends => [],
        };
    }
    <$sqlite>;

# Some libraries cause obscure issues.
# I have yet to diagnose them.
# Until then, blacklist them.
# @libraries =
#     grep {
#         $_->{url} !~ m:/tadzik/panda/:;
#     }
#     @libraries;

# Then we throw away garbage input.
# If you want your library in raku-nix,
# you must fix your META6.json.
 @libraries =
     map {
         if ($_->{meta_version} eq '*') {
             $_->{meta_version_p} = '0.0';
             $_->{meta_version} = "unstable";
         }


         $_;
     }
     @libraries;
# Now we keep only the latest version of each library.
my %latest =
    map  { $_->{meta_name} => $_ }
    sort { $a->{meta_version_p} <=> $b->{meta_version_p} }
    @libraries;
@libraries =
    sort { $a->{meta_name} cmp $b->{meta_name} }
    values(%latest);
undef(%latest);

# Insert some known build depends.
# TODO: CRAI should collect these instead.
for (@libraries) {
    if ($_->{meta_name} eq 'FastCGI::NativeCall') {
        $_->{meta_build_depends} = [ qw(LibraryMake Shell::Command) ];
    }
}

# Insert some known native depends.
# TODO: Specify these in a neat place.
for (@libraries) {
    if ($_->{meta_name} eq 'LibCurl') {
        $_->{meta_native_depends} = [ qw(curl) ];
    }
}

my @nix;

# Now we generate a Nix derivation for each latest version.
for (@libraries) {
    # Nix variables.
    my $url           = $_->{url};
    my $name          = nix_name($_->{meta_name});
    my $attrname      = nix_attr_name($_->{meta_name});
    my $version       = $_->{meta_version};
    my $sha256        = $_->{sha256_hash};
    my @nativeDepends = $_->{meta_native_depends}->@*;
    my @depends       = nix_depends($_->{meta_depends}->@*);
    push @depends, map { "pkgs.$_" } @nativeDepends;
    my @buildDepends  = nix_depends($_->{meta_build_depends}->@*);
#    say("{ pkgs, fetchurl, lib, rakuPackage, rakuPackages }");
    push @nix, ("  $attrname = buildRakuPackage {");
    push @nix, ("    name = \"$name\";");
    push @nix, ("    version = \"$version\";");
    push @nix, ("    buildInputs = [ @buildDepends ];") if @buildDepends;
    push @nix, ("    propagatedBuildInputs = [ @depends ];") if @depends;
    push @nix, ("    src = fetchurl {");
    push @nix, ("      url = \"$url\";");
    push @nix, ("      sha256 = \"$sha256\";");
    push @nix, ("    };");
    push @nix, ("  };");
}

print join("\n", @nix);

