use strict;
use Test::More 0.98;
use Getopt::Kingpin;


local @ARGV;
push @ARGV, qw(--name kingpin);

my $kingpin = Getopt::Kingpin->new;
$kingpin->flag('name', 'set name')->string();
$kingpin->parse;

is $kingpin->get('name'), 'kingpin';


done_testing;

