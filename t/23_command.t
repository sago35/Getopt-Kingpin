use strict;
use Test::More 0.98;
use Test::Exception;
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

done_testing;

