use strict;
use warnings;
use utf8;
use Test::More;
use Test::Trap;
use Getopt::Kingpin;

subtest 'run' => sub {
    my @tests = (
        {
            input    => "--completion-bash",
            expected => ["help", "one", "three", "two"],
        },
    );

    foreach my $test (@tests) {
        my $kingpin = Getopt::Kingpin->new;

        $kingpin->flag("flag-0", "")->string;
        $kingpin->flag("flag1", "")->hint_options("opt1", "opt2", "opt3")->string;

        my $one = $kingpin->command("one", "");

        my $two = $kingpin->command("two", "");
        $two->flag("flag-2", "")->string;
        $two->flag("flag-3", "")->hint_options("opt4", "opt5", "opt6")->string;

        my $three = $kingpin->command("three", "");
        $three->flag("flag-4", "")->string;
        $three->arg("arg-1", "")->string;
        $three->arg("arg-2", "")->hint_options("arg-2-opt-1", "arg-2-opt-2")->string;
        $three->arg("arg-3", "")->string;
        $three->arg("arg-4", "")->hint_options(sub {
                return "arg-4-opt-1", "arg-4-opt-2";
            })->string;


        my $input    = $test->{input};
        my $expected = [sort @{$test->{expected}}];

        trap {$kingpin->parse(split /\s+/, $input)};
        my $output   = [sort split /[\s\n]+/, $trap->stdout];

        is $trap->exit, 0;
        is_deeply $output, $expected, (sprintf "expected != actual: [%s] != [%s].\nInput was: [%s]", (join ", ", sort @{$output}), (join ", ", sort @{$expected}), $input);
    }
};

done_testing;

