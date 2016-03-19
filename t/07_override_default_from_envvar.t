use strict;
use Test::More 0.98;
use Test::Exception;
use Getopt::Kingpin;


subtest 'default' => sub {
    local @ARGV;
    push @ARGV, qw();

    $ENV{KINPIN_TEST_NAME} = "name from env var";

    my $kingpin = Getopt::Kingpin->new;
    my $name = $kingpin->flag('name', 'set name')->default("default name")->override_default_from_envar("KINPIN_TEST_NAME")->string();

    $kingpin->parse;

    is $name, 'name from env var';
};

done_testing;

