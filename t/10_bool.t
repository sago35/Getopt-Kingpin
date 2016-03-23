use strict;
use Test::More 0.98;
use Test::Exception;
use Getopt::Kingpin;


subtest 'bool' => sub {
    local @ARGV;
    push @ARGV, qw(--verbose);

    my $kingpin = Getopt::Kingpin->new;
    my $x = $kingpin->flag('verbose', 'set verbose mode')->bool();
    $kingpin->parse;

    ok $x;
};

subtest 'bool negative' => sub {
    local @ARGV;
    push @ARGV, qw(--no-verbose);

    my $kingpin = Getopt::Kingpin->new;
    my $x = $kingpin->flag('verbose', 'set verbose mode')->bool();
    $kingpin->parse;

    ok not $x;
};

subtest 'bool default' => sub {
    local @ARGV;
    push @ARGV, qw();

    my $kingpin = Getopt::Kingpin->new;
    my $x = $kingpin->flag('verbose', 'set verbose mode')->default(1)->bool();
    $kingpin->parse;

    ok $x;
};

subtest 'bool default 2' => sub {
    local @ARGV;
    push @ARGV, qw();

    my $kingpin = Getopt::Kingpin->new;
    my $x = $kingpin->flag('verbose', 'set verbose mode')->default(0)->bool();
    $kingpin->parse;

    ok not $x;
};

subtest 'bool required' => sub {
    local @ARGV;
    push @ARGV, qw(--verbose);

    my $kingpin = Getopt::Kingpin->new;
    my $x = $kingpin->flag('verbose', 'set verbose mode')->required()->bool();
    $kingpin->parse;

    ok $x;
};

subtest 'bool required 2' => sub {
    local @ARGV;
    push @ARGV, qw(--no-verbose);

    my $kingpin = Getopt::Kingpin->new;
    my $x = $kingpin->flag('verbose', 'set verbose mode')->required()->bool();
    $kingpin->parse;

    ok not $x;
};

subtest 'bool required 3' => sub {
    local @ARGV;
    push @ARGV, qw();

    my $kingpin = Getopt::Kingpin->new;
    my $x = $kingpin->flag('verbose', 'set verbose mode')->required()->bool();

    throws_ok {
        $kingpin->parse;
    } qr/required flag --verbose not provided/, 'required error';

};

done_testing;

