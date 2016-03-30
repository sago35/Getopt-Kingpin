requires 'perl', '5.008001';
requires 'Moo';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Exception';
    requires 'Test::Output';
};

