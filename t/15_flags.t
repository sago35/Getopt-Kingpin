use strict;
use Test::More 0.98;
use Test::Exception;
use Test::Trap;
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

subtest 'flags ordered help' => sub {
    local @ARGV;
    push @ARGV, qw(--help);

    my $kingpin = Getopt::Kingpin->new();
    my $verbose3 = $kingpin->flag('verbose3', 'Verbose mode.')->bool();
    my $verbose1 = $kingpin->flag('verbose1', 'Verbose mode.')->bool();
    my $verbose2 = $kingpin->flag('verbose2', 'Verbose mode.')->bool();

    trap {
        $kingpin->parse;
    };

    is $trap->stdout, sprintf <<'...', $0;
usage: %s [<flags>]

Flags:
      --help      Show context-sensitive help.
      --verbose3  Verbose mode.
      --verbose1  Verbose mode.
      --verbose2  Verbose mode.

...
};

done_testing;
