package Getopt::Kingpin;
use 5.008001;
use strict;
use warnings;
use Moo;
use Getopt::Kingpin::Flag;
use Carp;

our $VERSION = "0.01";

has flags => (
    is => 'rw',
    default => sub {return {}},
);

sub flag {
    my $self = shift;
    my ($name, $description) = @_;
    $self->flags({
            (map {$_ => $self->flags->{$_}} keys %{$self->flags}),
            $name => Getopt::Kingpin::Flag->new(
                name        => $name,
                description => $description,
            ),
        });
    return $self->flags->{$name};
}

sub parse {
    my $self = shift;
    my @_argv = @ARGV;
    $self->_parse(@_argv);
}

sub _parse {
    my $self = shift;
    my @argv = @_;

    while (scalar @argv > 0) {
        my $arg = shift @argv;
        if ($arg =~ /^--(?<name>\S+)$/) {
            my $value = shift @argv;
            my $v = $self->flags->{$+{name}};
            if ($v->type eq "string") {
                $v->value($value);
            } elsif ($v->type eq "int") {
                if ($value =~ /^-?[0-9]+$/) {
                    $v->value($value);
                } else {
                    croak "int parse error";
                }
            }
        }
    }
}

sub get {
    my $self = shift;
    my ($target) = @_;
    my $t = $self->flags->{$target};

    return $t->value;
}


1;
__END__

=encoding utf-8

=head1 NAME

Getopt::Kingpin - It's new $module

=head1 SYNOPSIS

    use Getopt::Kingpin;

=head1 DESCRIPTION

Getopt::Kingpin is ...

=head1 LICENSE

Copyright (C) sago35.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

sago35 E<lt>sago35@gmail.comE<gt>

=cut

