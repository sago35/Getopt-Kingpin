use strict;
use Test::More 0.98;
use Test::Exception;
use Getopt::Kingpin;


subtest 'invalid flag' => sub {
    local @ARGV;
    push @ARGV, qw(--verbose);

    my $kingpin = Getopt::Kingpin->new;

    throws_ok {
        $kingpin->parse;
    } qr/flag --verbose is not found/, 'invalid flag';
};

subtest 'invalid flag 2' => sub {
    local @ARGV;
    push @ARGV, qw(-v);

    my $kingpin = Getopt::Kingpin->new;

    throws_ok {
        $kingpin->parse;
    } qr/flag -v is not found/, 'invalid flag';
};

done_testing;

