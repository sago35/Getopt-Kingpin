use strict;
use Test::More 0.98;
use Test::Exception;
use Test::Output;
use Getopt::Kingpin;


subtest 'help' => sub {
    local @ARGV;
    push @ARGV, qw(--help);

    my $kingpin = Getopt::Kingpin->new();
    my $verbose = $kingpin->flag('verbose', 'Verbose mode.')->short('v')->bool();
    my $name    = $kingpin->arg('name', 'Name of user.')->required()->string();

    my $expected = sprintf <<'...', $0;
usage: %s [<flags>] <name>

Flags:
      --help     Show context-sensitive help.
  -v, --verbose  Verbose mode.

Args:
  <name>  Name of user.

...

    stdout_is {$kingpin->parse} $expected, 'simple help';
};


done_testing;

