use strict;
use Test::More 0.98;
use Test::Exception;
use Test::Trap;
use Getopt::Kingpin;

subtest 'repeatable flag error' => sub {
    local @ARGV;
    push @ARGV, qw(--xxx a --xxx b --xxx c);

    my $kingpin = Getopt::Kingpin->new();
    my $args = $kingpin->flag("xxx", "xxx yyy")->string();

    trap {
        my $cmd = $kingpin->parse;
    };

    like $trap->stderr, qr/error: flag 'xxx' cannot be repeated, try --help/;
    is $trap->exit, 1;
};

subtest 'repeatable flag (is_cumulative)' => sub {
    local @ARGV;
    push @ARGV, qw(--xxx a --xxx b --xxx c);

    my $kingpin = Getopt::Kingpin->new();
    my $args = $kingpin->flag("xxx", "xxx yyy")->string_list();
    #$args->is_cumulative(1);

    my $cmd = $kingpin->parse;

    is_deeply $args->value, ['a', 'b', 'c'];
};

done_testing;

