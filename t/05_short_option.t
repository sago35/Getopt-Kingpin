use strict;
use Test::More 0.98;
use Test::Trap;
use Getopt::Kingpin;


subtest 'short option' => sub {
    local @ARGV;
    push @ARGV, qw(-n kingpin);

    my $kingpin = Getopt::Kingpin->new;
    my $name = $kingpin->flag('name', 'set name')->short('n')->required->string();

    $kingpin->parse;

    is $name, 'kingpin';
};

subtest 'short and long option' => sub {
    local @ARGV;
    push @ARGV, qw(-n kingpin --xxxx 3);

    my $kingpin = Getopt::Kingpin->new;
    my $name = $kingpin->flag('name', 'set name')->short('n')->required->string();
    my $xxxx = $kingpin->flag('xxxx', 'set xxxx')->required->string();

    $kingpin->parse;

    is $name, 'kingpin';
    is $xxxx, 3;
};

subtest 'unknown short flag' => sub {
    local @ARGV;
    push @ARGV, qw(-h);

    my $kingpin = Getopt::Kingpin->new;

    trap {
        $kingpin->parse;
    };

    like $trap->stderr, qr/error: unknown short flag '-h', try --help/;
    is $trap->exit, 1;
};

done_testing;

