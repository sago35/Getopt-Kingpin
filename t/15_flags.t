use strict;
use Test::More 0.98;
use Test::Exception;
use Test::Output;
use Getopt::Kingpin;


subtest 'flag error' => sub {
    local @ARGV;
    push @ARGV, qw();

    my $kingpin = Getopt::Kingpin->new();
    my $verbose = $kingpin->flag('verbose', 'Verbose mode.')->short('v')->bool();
    throws_ok {
        my $verbose = $kingpin->flag('verbose', 'Verbose mode.')->bool();
    } qr/flag verbose is already exists/;

};

done_testing;

