[![Build Status](https://travis-ci.org/sago35/Getopt-Kingpin.svg?branch=master)](https://travis-ci.org/sago35/Getopt-Kingpin) [![Coverage Status](http://codecov.io/github/sago35/Getopt-Kingpin/coverage.svg?branch=master)](https://codecov.io/github/sago35/Getopt-Kingpin?branch=master)
# NAME

Getopt::Kingpin - command line options parser (like golang kingpin)

# SYNOPSIS

    use Getopt::Kingpin;
    my $kingpin = Getopt::Kingpin->new;
    $kingpin->flags->get("help")->short('h');
    my $verbose = $kingpin->flag('verbose', 'Verbose mode.')->short('v')->bool;
    my $name    = $kingpin->arg('name', 'Name of user.')->required->string;

    $kingpin->parse;

    # perl sample.pl hello
    printf "name : %s\n", $name;

With sub command.

    use Getopt::Kingpin;
    my $kingpin = Getopt::Kingpin->new;

    my $register      = $kingpin->command('register', 'Register a new user.');
    my $register_nick = $register->arg('nick', 'Nickname for user.')->required->string;
    my $register_name = $register->arg('name', 'Name for user.')->required->string;

    my $post       = $kingpin->command('post', 'Post a message to a channel.');
    my $post_image   = $post->flag('image', 'Image to post.')->file;
    my $post_channel = $post->arg('channel', 'Channel to post to.')->required->string;
    my $post_text    = $post->arg('text', 'Text to post.')->string_list;

    my $cmd = $kingpin->parse;

    if ($cmd eq 'register') {
        printf "register %s %s\n", $register_nick, $register_name;
    } elsif ($cmd eq 'post') {
        printf "post %s %s %s\n", $post_image, $post_channel, @{$post_text->value};
    } else {
        $kingpin->help;
    }

# DESCRIPTION

Getopt::Kingpin is a command line parser.
It supports flags and positional arguments.

Automatically generate help flag (--help).

This module is inspired by Kingpin written in golang.
https://github.com/alecthomas/kingpin

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

## parse(@arguments)

Parse @arguments.
If @arguments is empty, parse @ARGV.

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
