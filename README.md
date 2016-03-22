# NAME

Getopt::Kingpin - command line options parser (like golang kingpin)

# SYNOPSIS

    use Getopt::Kingpin;
    my $kingpin = Getopt::Kingpin->new;
    my $name = $kingpin->flag('name', 'set name')->string();
    $kingpin->parse;

    # perl sample.pl --name hello
    printf "name : %s\n", $name;

# DESCRIPTION

Getopt::Kingpin は、コマンドラインオプションを扱うモジュールです。
Golangのkingpinのperl版になるべく作成しています。
https://github.com/alecthomas/kingpin

# METHOD

## new()

Create a parser object.

    my $kingpin = Getopt::Kingpin->new;
    my $name = $kingpin->flag('name', 'set name')->string();
    $kingpin->parse;

## flag($name, $description)

Add and return Getopt::Kingpin::Flag object.

## parse()

Parse @ARGV.

## get($name)

Get Getopt::Kingpin::Flag instance of $name.

# LICENSE

Copyright (C) sago35.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

sago35 <sago35@gmail.com>
