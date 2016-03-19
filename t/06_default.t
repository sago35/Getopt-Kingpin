use strict;
use Test::More 0.98;
use Test::Exception;
use Getopt::Kingpin;


subtest 'default' => sub {
    local @ARGV;
    push @ARGV, qw();

    my $kingpin = Getopt::Kingpin->new;
    my $name = $kingpin->flag('name', 'set name')->default("default name")->string();
    my $xxxx = $kingpin->flag('xxxx', 'set xxxx')->string();

    $kingpin->parse;

    is $name, 'default name';
    is $xxxx, '';
};

done_testing;

