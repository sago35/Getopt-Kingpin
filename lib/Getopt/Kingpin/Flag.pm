package Getopt::Kingpin::Flag;
use 5.008001;
use strict;
use warnings;
use Moo;

our $VERSION = "0.01";

extends 'Getopt::Kingpin::Base';

has _placeholder => (
    is => 'rw',
);

sub placeholder {
    my $self = shift;
    my $placeholder = shift;

    $self->_placeholder($placeholder);

    return $self;
}

sub help_str {
    my $self = shift;

    my $ret = ["", "", ""];

    if (defined $self->short_name) {
        $ret->[0] = sprintf "-%s", $self->short_name;
    }

    if ($self->type eq "bool") {
        $ret->[1] = sprintf "--%s", $self->name;
    } else {
        if ($self->_placeholder) {
            $ret->[1] = sprintf '--%s=%s', $self->name, $self->_placeholder;
        } elsif ($self->_default) {
            $ret->[1] = sprintf '--%s="%s"', $self->name, $self->_default;
        } else {
            $ret->[1] = sprintf "--%s=%s", $self->name, uc $self->name;
        }
    }

    $ret->[2] = $self->description // "";

    return $ret;
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

=head2 short($short_name)

short optionを作成します。

=head2 default($default_value)

デフォルト値を設定します。

=head2 override_default_from_envar($env_var_name)

デフォルト値を環境変数で上書きします。

=head2 required()

そのオプションを必須とする。

=head2 help_str()

ヘルプ表示用の文字列をarray refで返します。

=head1 LICENSE

Copyright (C) sago35.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

sago35 E<lt>sago35@gmail.comE<gt>

=cut

