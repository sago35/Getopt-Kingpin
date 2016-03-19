package Getopt::Kingpin::Flag;
use 5.008001;
use strict;
use warnings;
use Moo;

our $VERSION = "0.01";

use overload (
    '""' => sub {$_[0]->value},
    '==' => sub {$_[0]->value},
    fallback => 1,
);

has name => (
    is => 'rw',
);

has description => (
    is => 'rw',
);

has value => (
    is => 'rw',
);

has type => (
    is => 'rw',
);

sub string {
    my $self = shift;

    $self->type("string");

    return $self;
}

sub int {
    my $self = shift;
    my ($type) = @_;

    $self->type("int");

    return $self;
}

1;
