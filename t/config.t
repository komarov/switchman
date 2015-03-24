use strict;
use warnings;

use App::Switchman;
use Test::More;

my $switchman = App::Switchman->new({
    command => 'dummy',
    lockname => 'dummy',
    prefix => '/dummy',
    zkhosts => 'localhost:2181',
});

is($switchman->termination_timeout, 10, 'default termination timeout');

my $switchman2 = App::Switchman->new({
    command => 'dummy',
    lockname => 'dummy',
    prefix => '/dummy',
    termination_timeout => 100,
    zkhosts => 'localhost:2181',
});

is($switchman2->termination_timeout, 100, 'overridden termination timeout');

done_testing;
