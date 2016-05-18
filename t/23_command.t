use strict;
use Test::More 0.98;
use Test::Exception;
use Test::Trap;
use Getopt::Kingpin;
use Getopt::Kingpin::Command;

subtest 'command (flag)' => sub {
    local @ARGV;
    push @ARGV, qw(post --server 127.0.0.1 --image=abc.jpg);

    my $kingpin = Getopt::Kingpin->new();
    my $post = $kingpin->command("post", "post image");
    my $server = $post->flag("server", "")->string();
    my $image = $post->flag("image", "")->file();

    $kingpin->parse;

    is ref $post, "Getopt::Kingpin::Command";
    is ref $server, "Getopt::Kingpin::Flag";
    is ref $image, "Getopt::Kingpin::Flag";

    is $server, "127.0.0.1";
    is $image, "abc.jpg";
};

subtest 'command (arg)' => sub {
    local @ARGV;
    push @ARGV, qw(post 127.0.0.1 abc.jpg);

    my $kingpin = Getopt::Kingpin->new();
    my $post = $kingpin->command("post", "post image");
    my $server = $post->arg("server", "")->string();
    my $image = $post->arg("image", "")->file();

    $kingpin->parse;

    is ref $post, "Getopt::Kingpin::Command";
    is ref $server, "Getopt::Kingpin::Arg";
    is ref $image, "Getopt::Kingpin::Arg";

    is $server, "127.0.0.1";
    is $image, "abc.jpg";
};

subtest 'command (flag and arg)' => sub {
    local @ARGV;
    push @ARGV, qw(post --server 127.0.0.1 abc.jpg);

    my $kingpin = Getopt::Kingpin->new();
    my $post = $kingpin->command("post", "post image");
    my $server = $post->flag("server", "")->string();
    my $image = $post->arg("image", "")->file();

    $kingpin->parse;

    is ref $post, "Getopt::Kingpin::Command";
    is ref $server, "Getopt::Kingpin::Flag";
    is ref $image, "Getopt::Kingpin::Arg";

    is $server, "127.0.0.1";
    is $image, "abc.jpg";
};

subtest 'command help' => sub {
    local @ARGV;
    push @ARGV, qw(--help);

    my $kingpin = Getopt::Kingpin->new();
    my $post = $kingpin->command("post", "post image");
    my $server = $post->flag("server", "")->string();
    my $image = $post->arg("image", "")->file();

    my $expected = sprintf <<'...', $0;
usage: %s [<flags>] <command> [<args> ...]

Flags:
  --help  Show context-sensitive help.

Commands:
  help [<command>...]
    Show help.

  post [<flags>] [<image>]
    post image


...

    trap {$kingpin->parse};
    is $trap->exit, 0;
    is $trap->stdout, $expected;
};

subtest 'command help' => sub {
    local @ARGV;
    push @ARGV, qw(--help);

    my $kingpin = Getopt::Kingpin->new();
    my $post = $kingpin->command("post", "post image");
    my $server = $post->flag("server", "")->string();
    my $image = $post->arg("image", "")->file();
    my $get  = $kingpin->command("get", "get image");

    my $expected = sprintf <<'...', $0;
usage: %s [<flags>] <command> [<args> ...]

Flags:
  --help  Show context-sensitive help.

Commands:
  help [<command>...]
    Show help.

  post [<flags>] [<image>]
    post image

  get
    get image


...

    trap {$kingpin->parse};
    is $trap->exit, 0;
    is $trap->stdout, $expected;
};

subtest 'command help' => sub {
    local @ARGV;
    push @ARGV, qw(--help);

    my $kingpin = Getopt::Kingpin->new();
    my $post = $kingpin->command("post", "post image");
    my $server = $post->flag("server", "")->string();
    my $get  = $kingpin->command("get", "get image");

    my $expected = sprintf <<'...', $0;
usage: %s [<flags>] <command> [<args> ...]

Flags:
  --help  Show context-sensitive help.

Commands:
  help [<command>...]
    Show help.

  post [<flags>]
    post image

  get
    get image


...

    trap {$kingpin->parse};
    is $trap->exit, 0;
    is $trap->stdout, $expected;
};

subtest 'command help 2' => sub {
    local @ARGV;
    push @ARGV, qw(help);

    my $kingpin = Getopt::Kingpin->new();
    my $post = $kingpin->command("post", "post image");
    my $server = $post->flag("server", "")->string();
    my $get  = $kingpin->command("get", "get image");

    my $expected = sprintf <<'...', $0;
usage: %s [<flags>] <command> [<args> ...]

Flags:
  --help  Show context-sensitive help.

Commands:
  help [<command>...]
    Show help.

  post [<flags>]
    post image

  get
    get image


...

    trap {$kingpin->parse};
    is $trap->exit, 0;
    is $trap->stdout, $expected;
};

subtest 'command help 3' => sub {
    local @ARGV;
    push @ARGV, qw(help post);

    my $kingpin = Getopt::Kingpin->new();
    my $post = $kingpin->command("post", "post image");
    my $server = $post->flag("server", "")->string();
    my $get  = $kingpin->command("get", "get image");

    my $expected = sprintf <<'...', $0;
usage: %s post [<flags>]

post image

Flags:
  --help           Show context-sensitive help.

  --server=SERVER


...

    trap {$kingpin->parse};
    is $trap->exit, 0;
    is $trap->stdout, $expected;
};

done_testing;

