use strict;
use Test::More 0.98;
use Test::Exception;
use Getopt::Kingpin;


subtest 'get' => sub {
    local @ARGV;
    push @ARGV, qw(--name=kingpin);

    my $kingpin = Getopt::Kingpin->new;
    $kingpin->flag('name', 'set name')->string();

    $kingpin->parse;

    my $name = $kingpin->get('name');
    is ref $name, 'Getopt::Kingpin::Flag';
    is $name, 'kingpin';
};

done_testing;

