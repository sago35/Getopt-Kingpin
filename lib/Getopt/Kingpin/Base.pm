package Getopt::Kingpin::Base;
use 5.008001;
use strict;
use warnings;
use Moo;
use Carp;
use Path::Tiny;

our $VERSION = "0.01";
our $types;
sub AUTOLOAD {
    no overloading;
    my $self = shift;
    my $func = our $AUTOLOAD;
    $func =~ s/.*:://;
    my $type = _camelize($func);

    $self->_set_types($type);

    $self->type($type);

    return $self;
}

sub _set_types {
    my $self = shift;
    my ($type) = @_;

    if (not exists $types->{$type}) {
        my $module = sprintf "Getopt::Kingpin::Type::%s", $type;
        if (not $module->can('set_value')) {
            croak "type error '$type'" unless eval "require $module"; ## no critic
        }
        $types->{$type} = {
            type      => \&{"${module}::type"},
            set_value => \&{"${module}::set_value"},
        };
    }

    if ($type eq "Bool") {
        if (not defined $self->_default) {
            $self->_default(0);
        }
    }
}

sub _camelize {
    my $c = shift;
    $c =~ s/(^|_)(.)/uc($2)/ge;
    return $c;
}

use overload (
    '""' => sub {$_[0]->value // ""},
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

has _default => (
    is => 'rw',
);

has _envar => (
    is => 'rw',
);

has type => (
    is => 'rw',
    default => sub {"String"},
);

has _required => (
    is => 'rw',
    default => sub {0},
);

has index => (
    is => 'rw',
    default => sub {0},
);


sub short {
    my $self = shift;
    my ($short_name) = @_;

    $self->short_name($short_name);

    return $self;
}

sub default {
    my $self = shift;
    my ($default) = @_;

    $self->_default($default);

    return $self;
}

sub override_default_from_envar {
    my $self = shift;
    my ($envar_name) = @_;

    if (exists $ENV{$envar_name}) {
        $self->_envar($ENV{$envar_name});
    }

    return $self;
}

sub required {
    my $self = shift;
    $self->_required(1);

    return $self;
}

sub set_value {
    my $type = $_[0]->type;

    $_[0]->_set_types($type);

    $types->{$type}->{set_value}->(@_);
}

1;
__END__

=encoding utf-8

=head1 NAME

Getopt::Kingpin::Flag - command line option object

=head1 SYNOPSIS

    use Getopt::Kingpin;
    my $kingpin = Getopt::Kingpin->new;
    my $name = $kingpin->flag('name', 'set name')->string();
    $kingpin->parse;

    printf "name : %s\n", $name;

=head1 DESCRIPTION

Getopt::Kingpin::Flag は、Getopt::Kingpinから使用するモジュールです。

=head1 METHOD

=head2 new()

Create Getopt::Kingpin::Flag object.

=head2 short($short_name)

short optionを作成します。

=head2 default($default_value)

デフォルト値を設定します。

=head2 override_default_from_envar($env_var_name)

デフォルト値を環境変数で上書きします。

=head2 required()

そのオプションを必須とする。

=head2 set_value($value)

$self->valueに値を設定します。
実際の処理ではGetopt::Kingpin::Type::以下のモジュールが使われます。

=head1 LICENSE

Copyright (C) sago35.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

sago35 E<lt>sago35@gmail.comE<gt>

=cut

