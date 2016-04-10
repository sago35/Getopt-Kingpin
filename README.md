[![Build Status](https://travis-ci.org/sago35/Getopt-Kingpin.svg?branch=master)](https://travis-ci.org/sago35/Getopt-Kingpin) [![Coverage Status](http://codecov.io/github/sago35/Getopt-Kingpin/coverage.svg?branch=master)](https://codecov.io/github/sago35/Getopt-Kingpin?branch=master)
# NAME

Getopt::Kingpin - command line options parser (like golang kingpin)

# SYNOPSIS

    use Getopt::Kingpin;
    my $kingpin = Getopt::Kingpin->new();
    $kingpin->flags->get("help")->short('h');
    my $verbose = $kingpin->flag('verbose', 'Verbose mode.')->short('v')->bool();
    my $name    = $kingpin->arg('name', 'Name of user.')->required()->string();

    $kingpin->parse;

    # perl sample.pl hello
    printf "name : %s\n", $name;

# DESCRIPTION

Getopt::Kingpin は、コマンドラインオプションを扱うモジュールです。
Golangのkingpinのperl版になるべく作成しています。
https://github.com/alecthomas/kingpin

Helpは、flag()やarg()から自動生成されます。

# METHOD

## new()

Create a parser object.

    my $kingpin = Getopt::Kingpin->new;
    my $name = $kingpin->flag('name', 'set name')->string();
    $kingpin->parse;

## flag($name, $description)

Add and return Getopt::Kingpin::Flag object.

## arg($name, $description)

Add and return Getopt::Kingpin::Arg object.

## parse()

Parse @ARGV.

## \_parse()

Parse @\_. Internal use only.

## get($name)

Get Getopt::Kingpin::Flag instance of $name.

## version($version)

Set application version to $version.

## help()

Print help.

# LICENSE

Copyright (C) sago35.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

sago35 <sago35@gmail.com>
