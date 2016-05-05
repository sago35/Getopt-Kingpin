use strict;
use Test::More 0.98;
use Test::Exception;
use Getopt::Kingpin;


subtest 'existing_dir' => sub {
    local @ARGV;
    push @ARGV, qw(lib);

    my $kingpin = Getopt::Kingpin->new();
    my $path = $kingpin->arg("path", "")->existing_dir();

    $kingpin->parse;

    my $x = $path->value;

    is $path, "lib";
    is ref $path, "Getopt::Kingpin::Arg";

    is $x, "lib";
    is ref $x, "Path::Tiny";

    is $x->is_dir, 1;
};

done_testing;

