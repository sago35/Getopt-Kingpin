use strict;
use Test::More 0.98;
use Test::Exception;
use Getopt::Kingpin;


subtest 'required' => sub {
    local @ARGV;
    push @ARGV, qw();

    my $kingpin = Getopt::Kingpin->new;
    $kingpin->flag('name', 'set name')->required->string();

    throws_ok {
        $kingpin->parse;
    } qr/required flag --name not provided/, 'required error';
};

subtest 'required and not required' => sub {
    local @ARGV;
    push @ARGV, qw(--name abc --x 3);

    my $kingpin = Getopt::Kingpin->new;
    my $name = $kingpin->flag('name', 'set name')->required->string();
    my $x = $kingpin->flag('x', 'set x')->int();

    lives_ok {
        $kingpin->parse;
    };

    is $name, 'abc';
    is $x, 3;
};

done_testing;

