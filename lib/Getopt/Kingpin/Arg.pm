package Getopt::Kingpin::Arg;
use 5.008001;
use strict;
use warnings;
use Getopt::Kingpin::Base -base;

our $VERSION = "0.04";

sub help_name {
    my $self = shift;
    my $mode = shift;

    if (not defined $mode) {
        $mode = 0;
    }

    my $ret = '<' . $self->name . '>';
    if ($mode and $self->is_cumulative) {
        $ret = $ret . '...';
    }
    if (not $self->_required) {
        $ret = '[' . $ret . ']';
    }
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

=head1 LICENSE

Copyright (C) sago35.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

sago35 E<lt>sago35@gmail.comE<gt>

=cut

