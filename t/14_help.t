use strict;
use Test::More 0.98;
use Test::Exception;
use Test::Trap;
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

    trap {$kingpin->parse};
    is $trap->exit, 0;
    is $trap->stdout, $expected;
};


subtest 'help short' => sub {
    local @ARGV;
    push @ARGV, qw(-h);

    my $kingpin = Getopt::Kingpin->new();
    $kingpin->flags->get("help")->short('h');
    my $verbose = $kingpin->flag('verbose', 'Verbose mode.')->short('v')->bool();
    my $name    = $kingpin->arg('name', 'Name of user.')->required()->string();

    my $expected = sprintf <<'...', $0;
usage: %s [<flags>] <name>

Flags:
  -h, --help     Show context-sensitive help.
  -v, --verbose  Verbose mode.

Args:
  <name>  Name of user.

...

    trap {$kingpin->parse};
    is $trap->exit, 0;
    is $trap->stdout, $expected;
};

subtest 'help max_length_of_flag' => sub {
    local @ARGV;
    push @ARGV, qw(-h);

    my $kingpin = Getopt::Kingpin->new();
    $kingpin->flags->get("help")->short('h');
    my $verbose = $kingpin->flag('verbose', 'Verbose mode.')->short('v')->bool();
    my $ip      = $kingpin->flag('ip', 'IP address.')->bool();

    my $expected = sprintf <<'...', $0;
usage: %s [<flags>]

Flags:
  -h, --help     Show context-sensitive help.
  -v, --verbose  Verbose mode.
      --ip       IP address.

...

    trap {$kingpin->parse};
    is $trap->exit, 0;
    is $trap->stdout, $expected;
};

subtest 'help max_length_of_flag 2' => sub {
    local @ARGV;
    push @ARGV, qw(-h);

    my $kingpin = Getopt::Kingpin->new();
    $kingpin->flags->get("help")->short('h');
    my $verbose = $kingpin->flag('verbose', 'Verbose mode.')->short('v')->bool();
    my $ip      = $kingpin->flag('ipaddress', 'IP address.')->bool();

    my $expected = sprintf <<'...', $0;
usage: %s [<flags>]

Flags:
  -h, --help       Show context-sensitive help.
  -v, --verbose    Verbose mode.
      --ipaddress  IP address.

...

    trap {$kingpin->parse};
    is $trap->exit, 0;
    is $trap->stdout, $expected;
};

done_testing;

