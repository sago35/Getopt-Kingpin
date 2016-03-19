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

has short_name => (
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

has _required => (
    is => 'rw',
    default => sub {0},
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

sub short {
    my $self = shift;
    my ($short_name) = @_;

    $self->short_name($short_name);

    return $self;
}

sub required {
    my $self = shift;
    $self->_required(1);

    return $self;
}

1;
