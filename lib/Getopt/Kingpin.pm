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

    my $required_but_not_found = {
        map {$_->name => $_} grep {$_->_required} values %{$self->flags}
    };
    while (scalar @argv > 0) {
        my $arg = shift @argv;
        if ($arg =~ /^(?:--(?<name>\S+?)(?<equal>=(?<value>\S+))?|-(?<short_name>\S+))$/) {
            my $name;
            if (defined $+{name}) {
                $name = $+{name};
            } elsif (defined $+{short_name}) {
                foreach my $f (values %{$self->flags}) {
                    if (defined $f->short_name and $f->short_name eq $+{short_name}) {
                        $name = $f->name;
                    }
                }
                if (not defined $name) {
                    croak sprintf "option -%s is not found", $+{short_name};
                }
            } else {
                croak;
            }
            delete $required_but_not_found->{$name} if exists $required_but_not_found->{$name};
            my $value = defined $+{equal} ? $+{value} : shift @argv;
            my $v = $self->flags->{$name};
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
    foreach my $r (values %$required_but_not_found) {
        croak sprintf "required flag --%s not provided", $r->name;
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

Getopt::Kingpin - command line options parser (like golang kingpin)

=head1 SYNOPSIS

    use Getopt::Kingpin;
    my $kingpin = Getopt::Kingpin->new;
    my $name = $kingpin->flag('name', 'set name')->string();
    $kingpin->parse;

    printf "name : %s\n", $name;

=head1 DESCRIPTION

Getopt::Kingpin は、コマンドラインオプションを扱うモジュールです。
Golangのkingpinのperl版になるべく作成しています。
https://github.com/alecthomas/kingpin

=head1 METHOD

=head2 new()

Create a parser object.

    my $kingpin = Getopt::Kingpin->new;
    my $name = $kingpin->flag('name', 'set name')->string();
    $kingpin->parse;

=head2 flag($name, $description)

Add and return Getopt::Kingpin::Flag object.

=head2 parse()

Parse @ARGV.

=head2 get($name)

Get value of $name.

=head1 LICENSE

Copyright (C) sago35.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

sago35 E<lt>sago35@gmail.comE<gt>

=cut

