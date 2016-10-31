package Getopt::Kingpin;
use 5.008001;
use strict;
use warnings;
use Object::Simple -base;
use Getopt::Kingpin::Flags;
use Getopt::Kingpin::Args;
use Getopt::Kingpin::Commands;
use File::Basename;
use Carp;

our $VERSION = "0.04";

use overload (
    '""' => sub {$_[0]->name},
    fallback => 1,
);

has flags => sub {
    my $flags = Getopt::Kingpin::Flags->new;
    $flags->add(
        name        => 'help',
        description => 'Show context-sensitive help.',
    )->bool();
    return $flags;
};

has args => sub {
    my $args = Getopt::Kingpin::Args->new;
    return $args;
};

has commands => sub {
    my $commands = Getopt::Kingpin::Commands->new;
    return $commands;
};

has _version => sub {
    return "";
};

has parent => sub {
    return
};

has name => sub {
    return basename($0);
};

has description => sub {
    return "";
};

sub new {
    my $class = shift;
    my @args = @_;

    my $self;
    if (@args == 2) {
        $self = $class->SUPER::new(
            name => $args[0],
            description => $args[1],
        );
    } else {
        $self = $class->SUPER::new(@args);
    }

    return $self;
}

sub flag {
    my $self = shift;
    my ($name, $description) = @_;
    my $ret = $self->flags->add(
        name        => $name,
        description => $description,
    );
    return $ret;
}

sub arg {
    my $self = shift;
    my ($name, $description) = @_;
    my $ret = $self->args->add(
        name        => $name,
        description => $description,
    );
    return $ret;
}

sub command {
    my $self = shift;
    my ($name, $description) = @_;
    if ($self->commands->count == 0) {
        $self->commands->add(
            name => "help",
            description => "Show help.",
        );
    }
    my $ret = $self->commands->add(
        name        => $name,
        description => $description,
        parent      => $self,
    );
    return $ret;
}

sub parse {
    my $self = shift;
    my @argv = @_;

    if (scalar @argv == 0) {
        @argv = @ARGV;
    }

    $self->_parse(@argv);
}

sub _parse {
    my $self = shift;
    my @argv = @_;

    my $required_but_not_found = {
        map {$_->name => $_} grep {$_->_required} $self->flags->values,
    };
    my $arg_index = 0;
    my $arg_only = 0;
    my $current_cmd;
    while (scalar @argv > 0) {
        my $arg = shift @argv;
        if ($arg eq "--") {
            $arg_only = 1;
        } elsif ($arg_only == 0 and $arg =~ /^--(no-)?(\S+?)(=(\S+))?$/) {
            my $no    = $1;
            my $name  = $2;
            my $equal = $3;
            my $val   = $4;

            delete $required_but_not_found->{$name} if exists $required_but_not_found->{$name};
            my $v = $self->flags->get($name);

            if (not defined $v) {
                printf STDERR "%s: error: unknown long flag '--%s', try --help", $self->name, $name;
                exit 1;
            }

            my $value;
            if ($v->type eq "Bool") {
                $value = defined $no ? 0 : 1;
            } elsif (defined $equal) {
                $value = $val;
            } else {
                $value = shift @argv;
            }

            $v->set_value($value);
        } elsif ($arg_only == 0 and $arg =~ /^-(\S+)$/) {
            my $short_name = $1;
            while (length $short_name > 0) {
                my ($s, $remain) = split //, $short_name, 2;
                my $name;
                foreach my $f ($self->flags->values) {
                    if (defined $f->short_name and $f->short_name eq $s) {
                        $name = $f->name;
                    }
                }
                if (not defined $name) {
                    printf STDERR "%s: error: unknown short flag '-%s', try --help", $self->name, $s;
                    exit 1;
                }
                delete $required_but_not_found->{$name} if exists $required_but_not_found->{$name};
                my $v = $self->flags->get($name);

                my $value;
                if ($v->type eq "Bool") {
                    $value = 1;
                } else {
                    if (length $remain > 0) {
                        $value = $remain;
                        $remain = "";
                    } else {
                        $value = shift @argv;
                    }
                }

                $v->set_value($value);
                $short_name = $remain;
            }
        } else {
            if ($arg_index == 0) {
                my $cmd = $self->commands->get($arg);
                if (defined $cmd) {
                    if ($cmd->name eq "help") {
                        $self->flags->get("help")->set_value(1)
                    } else {
                        my @argv_for_command = @argv;
                        @argv = ();

                        if ($self->flags->get("help")) {
                            push @argv_for_command, "--help";
                        }
                        $cmd->_parse(@argv_for_command);
                        $current_cmd = $cmd;
                        next;
                    }
                }
            }

            if (not ($arg_index == 0 and $arg eq "help")) {
                if ($arg_index < $self->args->count) {
                    $self->args->get($arg_index)->set_value($arg);
                    if (not $self->args->get($arg_index)->is_cumulative) {
                        $arg_index++;
                    }
                } else {
                    printf STDERR "%s: error: unexpected %s, try --help", $self->name, $arg;
                    exit 1;
                }
            }
        }
    }

    if ($self->flags->get("help")) {
        if (defined $current_cmd) {
            $current_cmd->help;
        } else {
            $self->help;
        }
        exit 0;
    }

    if ($self->flags->get("version")) {
        printf STDERR "%s\n", $self->_version;
        exit 0;
    }

    foreach my $f ($self->flags->values) {
        if (defined $f->value) {
            next;
        } elsif (defined $f->_envar) {
            $f->set_value($f->_envar);
        } elsif (defined $f->_default) {
            if ($f->type =~ /List$/) {
                foreach my $default (@{$f->_default}) {
                    $f->set_value($default);
                }
            } else {
                $f->set_value($f->_default);
            }
        } elsif ($f->type =~ /List$/) {
            $f->value([]);
        }
    }
    for (my $i = 0; $i < $self->args->count; $i++) {
        my $arg = $self->args->get($i);
        if (defined $arg->value) {
            next;
        } elsif (defined $arg->_envar) {
            $arg->set_value($arg->_envar);
        } elsif (defined $arg->_default) {
            if ($arg->type =~ /List$/) {
                foreach my $default (@{$arg->_default}) {
                    $arg->set_value($default);
                }
            } else {
            $arg->set_value($arg->_default);
            }
        } elsif ($arg->type =~ /List$/) {
            $arg->value([]);
        }
    }

    foreach my $r (values %$required_but_not_found) {
        printf STDERR "%s: error: required flag --%s not provided, try --help", $self->name, $r->name;
        exit 1;
    }
    for (my $i = 0; $i < $self->args->count; $i++) {
        my $arg = $self->args->get($i);
        if ($arg->_required and not $arg->_defined) {
            printf STDERR "%s: error: required arg '%s' not provided, try --help", $self->name, $arg->name;
            exit 1;
        }
    }

    return $current_cmd;
}

sub get {
    my $self = shift;
    my ($target) = @_;
    my $t = $self->flags->get($target);

    return $t;
}

sub version {
    my $self = shift;
    my ($version) = @_;

    my $f = $self->flags->add(
        name        => 'version',
        description => 'Show application version.',
    )->bool();
    $self->_version($version);
}

sub help_short {
    my $self = shift;
    my @help = ($self->name);

    push @help, "[<flags>]";

    if ($self->commands->count > 1) {
        push @help, "<command>";

        my $has_args = 0;
        foreach my $cmd ($self->commands->get_all) {
            if ($cmd->args->count > 0) {
                $has_args = 1;
            }
        }

        push @help, "[<args> ...]";
    } else {
        foreach my $arg ($self->args->get_all) {
            push @help, sprintf "<%s>", $arg->name;
        }
    }

    return join " ", @help;
}

sub help {
    my $self = shift;
    printf "usage: %s\n", $self->help_short;
    printf "\n";

    if ($self->description ne "") {
        printf "%s\n", $self->description;
        printf "\n";
    }

    printf "%s\n", $self->flags->help;

    if ($self->commands->count > 1) {
        printf "%s\n", $self->commands->help;
    } else {
        if ($self->args->count > 0) {
            printf "%s\n", $self->args->help;
        }
    }
}


1;
__END__

=encoding utf-8

=head1 NAME

Getopt::Kingpin - command line options parser (like golang kingpin)

=head1 SYNOPSIS

    use Getopt::Kingpin;
    my $kingpin = Getopt::Kingpin->new();
    $kingpin->flags->get("help")->short('h');
    my $verbose = $kingpin->flag('verbose', 'Verbose mode.')->short('v')->bool();
    my $name    = $kingpin->arg('name', 'Name of user.')->required()->string();

    $kingpin->parse;

    # perl sample.pl hello
    printf "name : %s\n", $name;

=head1 DESCRIPTION

Getopt::Kingpin is a command line parser.
It supports flags and positional arguments.

Automatically generate help flag (--help).

This module is inspired by Kingpin written in golang.
https://github.com/alecthomas/kingpin

=head1 METHOD

=head2 new()

Create a parser object.

    my $kingpin = Getopt::Kingpin->new;
    my $name = $kingpin->flag('name', 'set name')->string();
    $kingpin->parse;

=head2 flag($name, $description)

Add and return Getopt::Kingpin::Flag object.

=head2 arg($name, $description)

Add and return Getopt::Kingpin::Arg object.

=head2 parse(@arguments)

Parse @arguments.
If @arguments is empty, parse @ARGV.

=head2 _parse()

Parse @_. Internal use only.

=head2 get($name)

Get Getopt::Kingpin::Flag instance of $name.

=head2 version($version)

Set application version to $version.

=head2 help()

Print help.

=head1 LICENSE

Copyright (C) sago35.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

sago35 E<lt>sago35@gmail.comE<gt>

=cut

