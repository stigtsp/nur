# Tool to install raku modules (without zef)
# https://github.com/chloekek/raku-nix/blob/master/tools/install.p6

use v6.d;

sub MAIN(IO() :$dist-path, Str() :$repo-spec --> Nil) {
    my $dist = Distribution::Path.new($dist-path);
    my $repo = CompUnit::RepositoryRegistry.repository-for-spec($repo-spec);
    $repo.install($dist);
}
