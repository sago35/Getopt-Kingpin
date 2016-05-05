package Getopt::Kingpin::Base;
use 5.008001;
use strict;
use warnings;
use Moo;
use Carp;
use Path::Tiny;

our $VERSION = "0.01";

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
    default => sub {"string"},
);

has _required => (
    is => 'rw',
    default => sub {0},
);

has index => (
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

    $self->type("int");

    return $self;
}

sub bool {
    my $self = shift;

    $self->type("bool");
    if (not defined $self->_default) {
        $self->_default(0);
    }

    return $self;
}

sub file {
    my $self = shift;

    $self->type("file");

    return $self;
}

sub existing_file {
    my $self = shift;

    $self->type("existing_file");

    return $self;
}

sub existing_dir {
    my $self = shift;

    $self->type("existing_dir");

    return $self;
}

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
    my $self = shift;
    my ($value) = @_;

    if ($self->type eq "string") {
        $self->value($value);
    } elsif ($self->type eq "int") {
        if ($value =~ /^-?[0-9]+$/) {
            $self->value($value);
        } else {
            croak "int parse error";
        }
    } elsif ($self->type eq "bool") {
        $self->value($value);
    } elsif ($self->type eq "file") {
        my $p = path($value);
        $self->value($p);
    } elsif ($self->type eq "existing_file") {
        my $p = path($value);
        if ($p->is_dir) {
            croak sprintf "error: '%s' is a directory, try --help", $value;
        } elsif ($p->is_file) {
            $self->value($p);
        } else {
            croak sprintf "error: path '%s' does not exist, try --help", $value;
        }
    } elsif ($self->type eq "existing_dir") {
        my $p = path($value);
        if ($p->is_file) {
            croak sprintf "error: '%s' is a file, try --help", $value;
        } elsif ($p->is_dir) {
            $self->value($p);
        } else {
            croak sprintf "error: path '%s' does not exist, try --help", $value;
        }
    } else {
        croak sprintf "type error '%s'", $self->type;
    }
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

=head2 string()

自分自身をstringとして定義します。

=head2 int()

自分自身をintegerとして定義します。

=head2 bool()

自分自身をboolとして定義します。

=head2 file()

自分自身をfileとして定義します。

=head2 existing_file()

自分自身を存在しているfileとして定義します。
存在しない場合はエラーとなります。

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


=head1 LICENSE

Copyright (C) sago35.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

sago35 E<lt>sago35@gmail.comE<gt>

=cut

