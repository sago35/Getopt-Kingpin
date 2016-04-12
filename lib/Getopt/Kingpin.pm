package Getopt::Kingpin;
use 5.008001;
use strict;
use warnings;
use Moo;
use Getopt::Kingpin::Flags;
use Getopt::Kingpin::Arg;
use Carp;

our $VERSION = "0.01";

has flags => (
    is => 'rw',
    default => sub {
        my $flags = Getopt::Kingpin::Flags->new;
        $flags->add(
            name        => 'help',
            description => 'Show context-sensitive help.',
        )->bool();
        return $flags;
    },
);

has args => (
    is => 'rw',
    default => sub {return []},
);

has _version => (
    is => 'rw',
    default => sub {""},
);

has _name => (
    is => 'rw',
    default => sub {$0},
);

has _description => (
    is      => 'rw',
    default => sub {""},
);

around BUILDARGS => sub {
    my ($orig, $class, @args) = @_;

    if (@args == 2 and not ref $args[0]) {
        return +{
            _name => $args[0],
            _description => $args[1],
        };
    } else {
        return $class->$orig(@args);
    }
};

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
    my $arg = Getopt::Kingpin::Arg->new(
        name        => $name,
        description => $description,
    );
    $self->args([
            @{$self->args},
            $arg,
        ]);
    return $arg;
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
        map {$_->name => $_} grep {$_->_required} $self->flags->values,
    };
    my $arg_index = 0;
    while (scalar @argv > 0) {
        my $arg = shift @argv;
        if ($arg =~ /^--(?<no>no-)?(?<name>\S+?)(?<equal>=(?<value>\S+))?$/) {
            my $name = $+{name};

            delete $required_but_not_found->{$name} if exists $required_but_not_found->{$name};
            my $v = $self->flags->get($name);

            if (not defined $v) {
                printf STDERR "%s: error: unknown long flag '--%s', try --help", $self->_name, $name;
                exit 1;
            }

            my $value;
            if ($v->type eq "bool") {
                $value = defined $+{no} ? 0 : 1;
            } elsif (defined $+{equal}) {
                $value = $+{value}
            } else {
                $value = shift @argv;
            }

            $v->set_value($value);
        } elsif ($arg =~ /^-(?<short_name>\S+)$/) {
            my $name;
            foreach my $f ($self->flags->values) {
                if (defined $f->short_name and $f->short_name eq $+{short_name}) {
                    $name = $f->name;
                }
            }
            if (not defined $name) {
                printf STDERR "%s: error: unknown short flag '-%s', try --help", $self->_name, $+{short_name};
                exit 1;
            }
            delete $required_but_not_found->{$name} if exists $required_but_not_found->{$name};
            my $v = $self->flags->get($name);

            my $value;
            if ($v->type eq "bool") {
                $value = 1;
            } else {
                $value = shift @argv;
            }

            $v->set_value($value);
        } else {
            if ($arg_index < scalar @{$self->args}) {
                $self->args->[$arg_index]->value($arg);
                $arg_index++;
            }
        }
    }

    if ($self->flags->get("help")) {
        $self->help;
        exit 0;
    }

    if ($self->flags->get("version")) {
        printf STDERR "%s\n", $self->_version;
        exit 0;
    }

    foreach my $r (values %$required_but_not_found) {
        printf STDERR "%s: error: required flag --%s not provided, try --help", $self->_name, $r->name;
        exit 1;
    }
    for (my $i = 0; $i < scalar @{$self->args}; $i++) {
        my $arg = $self->args->[$i];
        if ($arg->_required and $i + 1 > $arg_index) {
            croak sprintf "required arg '%s' not provided", $arg->name;
        }
    }
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

sub help {
    my $self = shift;

    printf "usage: %s\n", join " ", $self->_name, "[<flags>]", map {sprintf "<%s>", $_->name} @{$self->args};
    printf "\n";

    if ($self->_description ne "") {
        printf "%s\n", $self->_description;
        printf "\n";
    }

    my $max_length_of_flag = 0;
    foreach my $flag ($self->flags->keys) {
        if ($max_length_of_flag < length $flag) {
            $max_length_of_flag = length $flag;
        }
    }
    my $flag_space = $max_length_of_flag + 2;

    printf "Flags:\n";
    foreach my $flag ($self->flags->values) {
        printf "  %-3s %-${flag_space}s  %s\n",
            defined $flag->short_name ? "-"  . $flag->short_name . "," : "",
            "--" . $flag->name,
            $flag->description;
    }
    printf "\n";

    if (scalar @{$self->args} > 0) {
        my $max_length_of_arg = 0;
        foreach my $arg (@{$self->args}) {
            if ($max_length_of_arg < length $arg->name) {
                $max_length_of_arg = length $arg->name;
            }
        }
        my $arg_space = $max_length_of_arg + 2;

        printf "Args:\n";
        foreach my $arg (@{$self->args}) {
            printf "  %-${arg_space}s  %s\n",
                '<' . $arg->name . '>',
                $arg->description;
        }
        printf "\n";
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

Getopt::Kingpin は、コマンドラインオプションを扱うモジュールです。
Golangのkingpinのperl版になるべく作成しています。
https://github.com/alecthomas/kingpin

Helpは、flag()やarg()から自動生成されます。

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

=head2 parse()

Parse @ARGV.

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

