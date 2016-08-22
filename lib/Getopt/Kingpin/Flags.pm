package Getopt::Kingpin::Flags;
use 5.008001;
use strict;
use warnings;
use Moo;
use Getopt::Kingpin::Flag;
use Carp;

our $VERSION = "0.03";

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
        return;
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

sub count {
    my $self = shift;
    return scalar $self->values;
}

sub _help_length {
    my $self = shift;

    my $len = [0, 0, 0];
    foreach my $f ($self->values) {
        my $str = $f->help_str;

        for (my $i = 0; $i < scalar @{$len}; $i++) {
            if ($len->[$i] < length $str->[$i]) {
                $len->[$i] = length $str->[$i];
            }
        }
    }

    return $len;
}

sub help {
    my $self = shift;
    my $ret = "";

    $ret .= "Flags:\n";

    my $len = $self->_help_length;
    foreach my $f ($self->values) {
        my $x = "";

        my $long = $len->[1];
        if ($len->[0] > 0) {
            if (defined $f->short_name) {
                $x .= sprintf "  %s, %-${long}s  %s\n", @{$f->help_str};
            } else {
                $x .= sprintf "      %-${long}s  %s\n", @{$f->help_str}[1, 2];
            }
        } else {
            $x .= sprintf "  %-${long}s  %s\n", @{$f->help_str}[1, 2];
        }
        $x =~ s/ +$//;
        $ret .= $x;
    }
    return $ret;
}

1;
__END__

=encoding utf-8

=head1 NAME

Getopt::Kingpin::Flags - command line option object

=head1 SYNOPSIS

    use Getopt::Kingpin::Flags;
    my $flags = Getopt::Kingpin::Flags->new;
    $flags->add(
        name        => 'help',
        description => 'Show context-sensitive help.',
    )->bool();

=head1 DESCRIPTION

Getopt::Kingpin::Flags は、Getopt::Kingpinから使用するモジュールです。
Flagを集合として扱います。

=head1 METHOD

=head2 new()

Create Getopt::Kingpin::Flags object.

=head2 add(name => $name, description => $description)

$name と $description をもつGetopt::Kingpin::Flagを生成し、管理します。

=head2 get($name)

$name で指定したGetopt::Kingpin::Flagを取り出します。

=head2 keys()

定義されている$nameの一覧の出力します。
add()した順で出力されます。

=head2 values()

定義されているGetopt::Kingpin::Flagをすべて出力します。
add()した順で出力されます。

=head2 _help_length()

short_name、name、descriptionの文字列長を返します。

=head2 help()

ヘルプを表示します。

=head1 LICENSE

Copyright (C) sago35.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

sago35 E<lt>sago35@gmail.comE<gt>

=cut

