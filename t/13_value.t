use strict;
use Test::More 0.98;
use Test::Exception;
use Getopt::Kingpin;


subtest 'default type' => sub {
    local @ARGV;
    push @ARGV, qw(--name=kingpin hello);

    my $kingpin = Getopt::Kingpin->new;
    my $name = $kingpin->flag('name', 'set name');
    my $word = $kingpin->arg('word', 'set word');

    $kingpin->parse;

    is $name, 'kingpin';
    is $word, 'hello';
};

done_testing;

