package Getopt::Kingpin::Flags;
use 5.008001;
use strict;
use warnings;
use Moo;
use Getopt::Kingpin::Flag;
use Carp;

our $VERSION = "0.01";

has _flags => (
    is => 'rw',
    default => sub {return {}},
);

sub add {
    my $self = shift;
    my $hash = {@_};
    my ($name, $description) = ($hash->{name}, $hash->{description});

    if (exists $self->_flags->{$name}) {
        croak sprintf "flag %s is already exists", $name;
    }

    $self->_flags->{$name} = Getopt::Kingpin::Flag->new(
        name        => $name,
        description => $description,
        index       => (scalar keys %{$self->_flags}),
    );

    return $self->_flags->{$name};
}

sub get {
    my $self = shift;
    my ($name) = @_;

    if (not exists $self->_flags->{$name}) {
        return undef;
    }

    return $self->_flags->{$name};

}

sub keys {
    my $self = shift;
    my @keys = sort {$self->_flags->{$a}->index <=> $self->_flags->{$b}->index} keys %{$self->_flags};
    return @keys;
}

sub values {
    my $self = shift;
    my @values = sort {$a->index <=> $b->index} values %{$self->_flags};
    return @values;
}

1;
